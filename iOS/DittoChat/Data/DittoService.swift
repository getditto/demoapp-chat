///
//  DittoService.swift
//  DittoChat
//
//  Created by Eric Turner on 2/24/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Combine
import DittoExportLogs
import DittoSwift
import SwiftUI


class DittoInstance: ObservableObject {
    @Published var loggingOption: DittoLogger.LoggingOptions
    private static let defaultLoggingOption: DittoLogger.LoggingOptions = .error    
    private var cancellables = Set<AnyCancellable>()
    
    static var shared = DittoInstance()
    let ditto: Ditto

    init() {
        ditto = Ditto(identity: DittoIdentity.offlinePlayground(appID: Env.DITTO_APP_ID))
        
        try! ditto.setOfflineOnlyLicenseToken(Env.DITTO_OFFLINE_TOKEN)
        
        // make sure our log level is set _before_ starting ditto.
        self.loggingOption = Self.storedLoggingOption()
        resetLogging()
        
        $loggingOption
            .dropFirst()
            .sink { [weak self] option in
                self?.saveLoggingOption(option)
                self?.resetLogging()
            }
            .store(in: &cancellables)            
        
        // v4 AddWins
        do {
            try ditto.disableSyncWithV3()
        } catch let error {
            print("ERROR: disableSyncWithV3() failed with error \"\(error)\"")
        }

        // Prevent Xcode previews from syncing: non preview simulators and real devices can sync
        let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isPreview {
            try! ditto.startSync()
        }
        
        do {
            try ditto.sync.registerSubscription(query: "SELECT * FROM \(usersKey)")
        } catch {
            print("Error \(error)")
        }

    }
}
extension DittoInstance {
    enum UserDefaultsKeys: String {
        case loggingOption = "live.ditto.CountDataFetch.userDefaults.loggingOption"
    }
}

extension DittoInstance {
    fileprivate func storedLoggingOption() -> DittoLogger.LoggingOptions {
        return Self.storedLoggingOption()
    }
    // static function for use in init() at launch
    fileprivate static func storedLoggingOption() -> DittoLogger.LoggingOptions {
        if let logOption = UserDefaults.standard.object(
            forKey: UserDefaultsKeys.loggingOption.rawValue
        ) as? Int {
            return DittoLogger.LoggingOptions(rawValue: logOption)!
        } else {
            return DittoLogger.LoggingOptions(rawValue: defaultLoggingOption.rawValue)!
        }
    }
    
    fileprivate func saveLoggingOption(_ option: DittoLogger.LoggingOptions) {
        UserDefaults.standard.set(option.rawValue, forKey: UserDefaultsKeys.loggingOption.rawValue)
    }

    fileprivate func resetLogging() {
        let logOption = Self.storedLoggingOption()
        switch logOption {
        case .disabled:
            DittoLogger.enabled = false
        default:
            DittoLogger.enabled = true
            DittoLogger.minimumLogLevel = DittoLogLevel(rawValue: logOption.rawValue)!
            if let logFileURL = DittoLogManager.shared.logFileURL {
                DittoLogger.setLogFileURL(logFileURL)
            }
        }
    }
}


class DittoService: ReplicatingDataInterface {
    @Published var publicRoomsPublisher = CurrentValueSubject<[Room], Never>([])
    @Published fileprivate private(set) var allPublicRooms: [Room] = []
    private var allPublicRoomsCancellable: AnyCancellable = AnyCancellable({})
    private var cancellables = Set<AnyCancellable>()
    
    // private in-memory stores of subscriptions for rooms and messages
    private var privateRoomSubscriptions = [String: DittoSyncSubscription]()
    private var privateRoomMessagesSubscriptions = [String: DittoSyncSubscription]()
    private var publicRoomMessagesSubscriptions = [String: DittoSyncSubscription]()

    private let ditto = DittoInstance.shared.ditto
    private var privateStore: LocalDataInterface
    
    private var joinRoomQuery: DittoSwift.DittoLiveQuery?
    
    init(privateStore: LocalDataInterface) {
        self.privateStore = privateStore

        createDefaultPublicRoom()
        
        // kick off the public rooms findAll() liveQueryPublisher
        updateAllPublicRooms()
        
        // filter out archived public rooms, add subscriptions, set @Published publicRooms property
        $allPublicRooms
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pubRooms in
                var rooms = pubRooms.filter { room in
                    !privateStore.archivedPublicRoomIDs.contains(room.id)
                }
                rooms.sort { $0.createdOn > $1.createdOn }
                
                // add subscriptions in case a new one has come in
                /* Note: maybe this could be more efficient, as all subscriptions are all
                 re-initialized each time the collection[rooms] findAll query fires */
                rooms.forEach {[weak self] room in
                    self?.addSubscriptions(for: room)
                }

                self?.publicRoomsPublisher.value = rooms
            }
            .store(in: &cancellables)

        // update subscriptions for private rooms at launch and for every change
        privateStore.privateRoomsPublisher
            .sink {[weak self] rooms in
                // clear storage variables
                self?.privateRoomSubscriptions.removeAll(keepingCapacity: true)
                self?.privateRoomMessagesSubscriptions.removeAll(keepingCapacity: true)
                rooms.forEach { room in
                    self?.addSubscriptions(for: room)
                }
            }
            .store(in: &cancellables)
    }
}

///  General Overview
///  Public rooms are "public" by reason of the `findAll()` liveQueryPublisher on the `ditto.store["rooms"]` collection being
///  persisted in memory for the lifecycle of the app. All newly created public rooms on the mesh automatically replicate because of the
///  `findAll()` query.
///
///  All rooms have thier own messages collection, named with a UUID string, stored in the `room.messagesId` property. This avoids
///  the Ditto db performance bottleneck of having a single "messages" collection, where queries for messages for a given room would
///  require an all-table scan of all messages for every query. Each room can simply `findAll()` on its own messages collection.
///
///  Private rooms each have their own room collection, named with a UUID string, stored in the `room.collectionId` property. This
///  makes the room "private" in that subscriptions to the room require knowing the UUID string collection name, whereas public rooms all
///  reside, and are replicated from, the known "rooms" collection, i.e., `ditto.store["rooms"]`. Both private and public rooms each
///  have their own messages collection, named with a UUID string, stored in the `room.messagesId` property.
///
/// Subscriptions Overview
///  `DittoSubscription` objects subscribing to room and messages collections must be kept in memory througout the lifecycle
///  of the app. This enables messages to replicate into the local Ditto db from the mesh, regardless of whether the user is currently
///  viewing a given room. (For each navigation into a room, a liveQueryPublisher publishes messages for that room in real time for the
///  lifecycle of the view model that subscribes to the publisher. Even though the publisher is released after navigating out of the room, the
///  subscription object continues to replicate messages from the mesh. This ensures messages are always kept up to date.)
///
///  Subscriptions are added to subscription dictionary variables for every update of the `allPublicRooms` publisher after filtering out
///  archived rooms, and for every update of the `privateStore.privateRoomPublisher`for private rooms.
///
///  Public room `findAll()` subscriptions for their messages collection are created for every update of the `allPublicRooms`
///  publisher (after filtering out archived public rooms), and stored  in the private `publicRoomMessageSubscriptions` variable
///  of type `[String: DittoSubscription]`, where the key is the `room.id` and value is the subscription.
///
///  Private Rooms require subscriptions for both the room collection (`room.collectionId`) and its messages collection
///  (`room.messagesId`). These are stored in the private `privateRoomSubscriptions` and
///  `privateRoomMessagesSubscriptions` variables, both of type `[String: DittoSubscription]`, where for the
///  former the key is the `room.collectionId`, and the latter, the `room.messagesId`, and for both, the value is the
///  `findAll()` subscription on the collection.
///
///  Subscriptions are added at launch for all non-archived public and private rooms via the publishers described above. The
///  `addSubscriptions` and `removeSubscriptions`functions are addtionally used by archiving and unarchiving functions,
///  as well as joining a private room via QR code.
extension DittoService {
    //MARK: Subscriptions
    
    func addSubscriptions(for room: Room) {
        if room.isPrivate {
            addPrivateRoomSubscriptions(roomId: room.id, collectionId: room.collectionId!, messagesId: room.messagesId)
        } else {
            
            do {
                let mSub = try ditto.sync.registerSubscription(query: "SELECT * FROM \"\(room.messagesId)\"")
                publicRoomMessagesSubscriptions[room.id] = mSub

            } catch {
                print("Error \(error)")
            }
        }
    }
    
    func removeSubscriptions(for room: Room) {
        if room.isPrivate {
            guard let rSub = privateRoomSubscriptions[room.id] else {
                print("\(#function) private room subscription NOT FOUND in privateRoomSubscriptions --> RETURN")
                return
            }
            rSub.cancel()
            privateRoomSubscriptions.removeValue(forKey: room.id)
            
            guard let mSub = privateRoomMessagesSubscriptions[room.id] else {
                print("\(#function) privateRoomMessagesSubscriptions subcription NOT FOUND --> RETURN")
                return
            }
            mSub.cancel()
            privateRoomMessagesSubscriptions.removeValue(forKey: room.id)
        } else {
            guard let rSub = publicRoomMessagesSubscriptions[room.id] else {
                print("\(#function) publicRoomMessagesSubscriptions subcription NOT FOUND --> RETURN")
                return
            }
            rSub.cancel()
            publicRoomMessagesSubscriptions.removeValue(forKey: room.id)
        }
    }

    // This function without room param is for qrCode join private room, where there isn't yet a room
    func addPrivateRoomSubscriptions(roomId: String, collectionId: String, messagesId: String) {
        
        do {
            let rSub = try ditto.sync.registerSubscription(query: "SELECT * FROM \"\(collectionId)\"")
            privateRoomSubscriptions[roomId] = rSub
            
            let mSub = try ditto.sync.registerSubscription(query: "SELECT * FROM \"\(messagesId)\"")
            privateRoomMessagesSubscriptions[roomId] = mSub


        } catch {
            print("Error \(error)")
        }
    }
}
    
extension DittoService {
    //MARK: Users
    
    func currentUserPublisher() -> AnyPublisher<User?, Never> {
        privateStore.currentUserIdPublisher
            .map { userId -> AnyPublisher<User?, Never> in
                guard let userId = userId else {
                    return Just<User?>(nil).eraseToAnyPublisher()
                }

                return self.ditto.store.observePublisher(query: "SELECT * FROM \(usersKey) WHERE _id = :id", arguments: ["id":userId], mapTo: User.self, onlyFirst: true)
                    .catch { error in
                        assertionFailure("ERROR with \(#function)" + error.localizedDescription)
                        return Empty<User?, Never>()
                    }
                    .removeDuplicates()
                    .compactMap { $0 } // Remove nil values
                    .eraseToAnyPublisher()
                
                
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func addUser(_ usr: User) {
        
        Task {
            do {
                try await ditto.store.execute(query: "INSERT INTO \(usersKey) DOCUMENTS (:newUser) ON ID CONFLICT DO UPDATE", arguments: ["newUser": usr.docDictionary()])
            } catch {
                print("Error \(error)")
            }
        }
    }

    func allUsersPublisher() -> AnyPublisher<[User], Never>  {

        return ditto.store.observePublisher(query: "SELECT * FROM \(usersKey)", mapTo: User.self)
            .catch { error in
                assertionFailure("ERROR with \(#function)" + error.localizedDescription)
                return Empty<[User], Never>()
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

//MARK: Messages
extension DittoService {
    
    func messagePublisher(for msgId: String, in collectionId: String) -> AnyPublisher<Message, Never> {
        
        let query = "SELECT * FROM COLLECTION \"\(collectionId)\" (\(thumbnailImageTokenKey) ATTACHMENT, \(largeImageTokenKey) ATTACHMENT) WHERE _id = :id"
        
        let args = ["id": msgId]
        
        return ditto.store.observePublisher(query: query, arguments: args, mapTo: Message.self, onlyFirst: true)
            .catch { error in
                assertionFailure("ERROR with \(#function)" + error.localizedDescription)
                return Empty<Message?, Never>()
            }
            .removeDuplicates()
            .compactMap { $0 } // Remove nil values
            .eraseToAnyPublisher()
        
    }

    func messagesPublisher(for room: Room) -> AnyPublisher<[Message], Never> {

        return ditto.store.observePublisher(query: "SELECT * FROM COLLECTION \"\(room.messagesId)\" (\(thumbnailImageTokenKey) ATTACHMENT, \(largeImageTokenKey) ATTACHMENT) ORDER BY \(createdOnKey) ASC", mapTo: Message.self)
            .catch { error in
                assertionFailure("ERROR with \(#function)" + error.localizedDescription)
                return Empty<[Message], Never>()
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
        
    }
    
    func createMessage(for room: Room, text: String) async {
        guard let userId = privateStore.currentUserId else {
            return
        }
        
        guard let room = await self.room(for: room) else {
            return
        }
        
        Task {
            do {
                let doc = [
                    createdOnKey: DateFormatter.isoDate.string(from: Date()),
                    roomIdKey: room.id,
                    textKey: text,
                    userIdKey: userId
                ];
                
                try await ditto.store.execute(query: "INSERT INTO \"\(room.messagesId)\" DOCUMENTS (:newDoc) ON ID CONFLICT DO UPDATE", arguments: ["newDoc": doc])

            } catch {
                print("Error \(error)")
            }
            
        }
    }
    
    func saveEditedTextMessage(_ message: Message, in room: Room) {
        Task {
            do {
                try await ditto.store.execute(query: "UPDATE \"\(room.messagesId)\" SET \(textKey) = \'\(message.text)\' WHERE _id = :id", arguments: ["id": message.id])
            } catch {
                print("Error \(error)")
            }
        }
    }

    func saveDeletedImageMessage(_ message: Message, in room: Room) {

        Task {
            do {
                let query = "UPDATE COLLECTION \"\(room.messagesId)\" (\(thumbnailImageTokenKey) ATTACHMENT, \(largeImageTokenKey) ATTACHMENT) SET \(thumbnailImageTokenKey) -> tombstone(), \(largeImageTokenKey) -> tombstone(), \(textKey) = :text WHERE _id = :id"
                
                let args = [
                    "id": message.id,
                    "text": message.text
                ]
                
                try await ditto.store.execute(query: query, arguments: args)
            } catch {
                print("Error \(error)")
            }
        }
        
    }

    // image param expected to be native image size/resolution, from which downsampled thumbnail will be derived
    func createImageMessage(for room: Room, image: UIImage, text: String?) async throws {
        let userId = privateStore.currentUserId ?? createdByUnknownKey
        var nowDate = DateFormatter.isoDate.string(from: Date())
        var fname = await attachmentFilename(for: user(for: userId), type: .thumbnailImage, timestamp: nowDate)

        //------------------------------------- Thumbnail ------------------------------------------
        guard let thumbnailImg = await image.attachmentThumbnail() else {
            print("DittoService.\(#function): ERROR - expected non-nil thumbnail")
            throw AttachmentError.thumbnailCreateFail
        }
        
        guard let tmpStorage = try? TemporaryFile(creatingTempDirectoryForFilename: "thumbnail.jpg") else {
            print("DittoService.\(#function): Error creating TMP storage directory")
            throw AttachmentError.tmpStorageCreateFail
        }

        guard let _ = try? thumbnailImg.jpegData(compressionQuality: 1.0)?.write(to: tmpStorage.fileURL) else {
            print("Error writing JPG attachment data to file at path: \(tmpStorage.fileURL.path) --> Throw")
            throw AttachmentError.tmpStorageWriteFail
        }
        
        guard let thumbAttachment = try? await ditto.store.newAttachment(
            path: tmpStorage.fileURL.path,
            metadata: metadata(for: image, fname: fname, timestamp: nowDate)
        ) else {
            print("Error creating Ditto image attachment from thumbnail jpg data --> Throw")
            throw AttachmentError.createFail
        }
        
        // create new message doc with thumbnail attachment
        let docId = UUID().uuidString

        let capturedNowDate = nowDate

        Task {
            do {
                let doc: [String: Any?] = [
                    dbIdKey: docId,
                    createdOnKey: capturedNowDate,
                    roomIdKey: room.id,
                    userIdKey: userId,
                    thumbnailImageTokenKey: thumbAttachment
                ];
                
                try await ditto.store.execute(query: "INSERT INTO COLLECTION \"\(room.messagesId)\" (\(thumbnailImageTokenKey) ATTACHMENT) DOCUMENTS (:newDoc)", arguments: ["newDoc": doc, "\(thumbnailImageTokenKey)": thumbAttachment])
   
                try await cleanupTmpStorage(tmpStorage.deleteDirectory)
            } catch {
                print("Error \(error)")
                throw error
            }
        }
        //------------------------------------------------------------------------------------------
        
        //------------------------------------- Large Image  ---------------------------------------
        nowDate = DateFormatter.isoDate.string(from: Date())
        fname = await attachmentFilename(for: user(for: userId), type: .largeImage, timestamp: nowDate)

        guard let tmpStorage = try? TemporaryFile(creatingTempDirectoryForFilename: "largeImage.jpg") else {
            print("DittoService.\(#function): Error creating TMP storage directory")
            throw AttachmentError.tmpStorageCreateFail
        }

        guard let _ = try? image.jpegData(compressionQuality: 1.0)?.write(to: tmpStorage.fileURL) else {
            print("Error writing JPG attachment data to file at path: \(tmpStorage.fileURL.path) --> Return")
            throw AttachmentError.tmpStorageWriteFail
        }
        
        guard let largeAttachment = try? await ditto.store.newAttachment(
            path: tmpStorage.fileURL.path,
            metadata: metadata(for: image, fname: fname, timestamp: nowDate)
        ) else {
            print("Error creating Ditto image attachment from large jpg data --> Throw")
            throw AttachmentError.createFail
        }
        
        Task {
            do {
                let query = "UPDATE COLLECTION \"\(room.messagesId)\" (\(largeImageTokenKey) ATTACHMENT) SET \(largeImageTokenKey) = :largeAttachment WHERE _id = :id"
                
                let args = [
                    "id": docId,
                    "largeAttachment": largeAttachment
                ]
                
                let _ = try await ditto.store.execute(query: query, arguments: args)
            } catch {
                print("Error \(error)")
            }
        }
        
        
        do {
            try await cleanupTmpStorage(tmpStorage.deleteDirectory)
        } catch {
            throw error
        }
    }

    private func metadata(for image:UIImage, fname: String, timestamp: String) async -> [String: String] {
        await [
            /*
             Note: "filename" in the metadata is used when displaying a large image attachment in
             a QLPreviewController, and will be the filename if the image is shared from there.
             However, the DittoAttachment created with this metadata is initialized (above) from
             a tmp storage location, and there is no actual "file" after tmp storage cleanup.
             
             Also note that the metadata property of DittoAttachment is an empty [String:String] by
             default. For this example app, fairly rich metadata is generated which could be used
             for display in various viewing contexts, and not all of it is displayed in this app.
             */
            filenameKey: fname,
            userIdKey: privateStore.currentUserId ?? "",
            usernameKey: user(for: privateStore.currentUserId ?? "")?.fullName ?? unknownUserNameKey,
            fileformatKey: jpgExtKey,
            filesizeKey: String(image.sizeInBytes),
            timestampKey: timestamp
        ]
    }

    private func cleanupTmpStorage(_ cleanup: () throws -> Void) async throws {
        do {
            try cleanup()
        } catch {
            throw AttachmentError.tmpStorageCleanupFail
        }
    }

    // example filename output: John-Doe_thumbnail_2023-05-19T23-19-01Z.jpg
    private func attachmentFilename(
        for user: User?,
        type: AttachmentType,
        timestamp: String,
        ext: String = jpgExtKey
    ) async -> String {
        var fname = await self.user(for: privateStore.currentUserId ?? "")?.fullName ?? unknownUserNameKey
        fname = fname.replacingOccurrences(of: " ", with: "-")
        let tmstamp = timestamp.replacingOccurrences(of: ":", with: "-")
        fname += "_\(type.description)" + "_\(tmstamp)" + ext
        
        return fname
    }
    
    private func user(for userId: String) async -> User? {
       
       do {
           let result = try await ditto.store.execute(query: "SELECT * FROM \(usersKey) WHERE _id = :id", arguments: ["id": userId])
           if let userValue = result.items.first?.value {
               return User(value: userValue)
           }
       } catch {
           print("Error \(error)")
       }
       
       return nil
   }
    //  --------------------------------------------------------------------------------------------
    
    
    /* DISUSED BECAUSE PROGRESS PUBLISHER BUG (refactored in BubbleViewVM */
    func attachmentPublisher(
        for token: DittoAttachmentToken,
        in collectionId: String
    ) -> DittoSwift.DittoStore.FetchAttachmentPublisher {
        ditto.store.fetchAttachmentPublisher(attachmentToken: token)
    }
}

extension DittoService {
    //MARK: Rooms
    
    private func updateAllPublicRooms() {
        
        allPublicRoomsCancellable = ditto.store.observePublisher(query: "SELECT * FROM \(publicRoomsCollectionId) ORDER BY \(createdOnKey) ASC", mapTo: Room.self)
            .catch { error in
                assertionFailure("ERROR with \(#function)" + error.localizedDescription)
                return Empty<[Room], Never>()
            }
            .assign(to: \.allPublicRooms, on: self)
    }
    
    func roomPublisher(for room: Room) -> AnyPublisher<Room?, Never> {

        ditto.store.observePublisher(query: "SELECT * FROM \"\(room.isPrivate ? room.collectionId! : publicRoomsCollectionId)\" WHERE _id = :id", arguments: ["id":room.id], mapTo: Room.self, onlyFirst: true)
            .catch { error in
                assertionFailure("ERROR with \(#function)" + error.localizedDescription)
                return Empty<Room?, Never>()
            }
            .removeDuplicates()
            .compactMap { $0 } // Remove nil values
            .eraseToAnyPublisher()
    }
    
    /// This function returns a room from the Ditto db for the given room. The room argument will be passed from the UI, where
    /// placeholder Room instances are used to display, e.g., archived rooms. In other cases, they are rooms from a publisher of
    /// Room instances,
    func room(for room: Room) async -> Room? {
        let collectionId = room.collectionId ?? publicRoomsCollectionId
        
        do {
            let result = try await ditto.store.execute(query: "SELECT * FROM \"\(collectionId)\" WHERE _id = :id", arguments: ["id": room.id])

            if result.items.isEmpty {
                print("DittoService.\(#function): WARNING (except for archived private rooms)" +
                      " - expected non-nil room room.id: \(room.id)"
                )
                return nil
            }
            
            if let itemValue = result.items.first?.value {
                return Room(value: itemValue)
            }
            
        } catch {
            print("Error \(error)")
        }
        
        return nil

    }
    
    func publicRooms(for rooms: [Room]) async -> (arr1: [Room], arr2: [Room]) {
        let collectionId = publicRoomsCollectionId
        var arr1 = [Room]()
        var arr2 = [Room]()
        for room in rooms {
            do {
                let result = try await ditto.store.execute(
                    query: "SELECT * FROM \"\(collectionId)\" WHERE _id = :id",
                    arguments: ["id": room.id]
                )
                if let resultRoom = result.items.first {
                    arr1.append(Room(value: resultRoom.value))
                } else {
                    arr2.append(room)
                }
            } catch {
                print("Error \(error)")
            }
        }
        return (arr1, arr2)
    }
    
//    func privateRooms(for rooms: [Room]) async -> (arr1: [Room], arr2: [Room]) {
//        
//    }
    
    func createRoom(name: String, isPrivate: Bool) {
        let roomId = UUID().uuidString
        let messagesId = UUID().uuidString
        let collectionId = isPrivate ? UUID().uuidString : publicRoomsCollectionId
        
        let room = Room(
            id: roomId,
            name: name,
            messagesId: messagesId,
            isPrivate: isPrivate,
            collectionId: collectionId
        )
        
        addSubscriptions(for: room)
        
        Task {
            do {
                try await ditto.store.execute(query: "INSERT INTO \"\(collectionId)\" DOCUMENTS (:newDoc) ON ID CONFLICT DO UPDATE", arguments: ["newDoc": room.docDictionary()])
            } catch {
                print("Error \(error)")
            }
        }
        
        if isPrivate {
            privateStore.addPrivateRoom(room)
        }
    }
    
    func joinPrivateRoom(qrCode: String) {
        let parts = qrCode.split(separator: "\n")
        guard parts.count == 7 else {
            print("DittoService.\(#function): Error - expected 7 parts to QR code: \(qrCode) --> RETURN")
            return
        }
        // parse qrCode for roomId, collectionId, messagesId
        let roomId = String(parts[0])
        let collectionId = String(parts[1])
        let messagesId = String(parts[2])
        let roomName = String(parts[3])
        let isPrivate = Bool(String(parts[4])) ?? true
        let createdBy = String(parts[5])
        let createdOn = DateFormatter.isoDate.date(from: String(parts[6]))
        
        addPrivateRoomSubscriptions(
            roomId: roomId,
            collectionId: collectionId,
            messagesId: messagesId
        )
        
        let room = Room(id: roomId, name: roomName, messagesId: messagesId, isPrivate: isPrivate, collectionId: collectionId, createdBy: createdBy, createdOn: createdOn)
        
        self.privateStore.addPrivateRoom(room)
        
    }
    
    private func createDefaultPublicRoom() {
        // Only create default Public room if user does not yet exist, i.e. first launch
        if privateStore.currentUserId != nil {
//        if allPublicRooms.count > 0 {
            return
        }
        
        // Create default Public room with pre-configured id, messagesId
        
        Task {
            do {
                let newDoc: [String: Any?] = [
                    dbIdKey: publicKey,
                    nameKey: publicRoomTitleKey,
                    collectionIdKey: publicRoomsCollectionId,
                    messagesIdKey: publicMessagesIdKey,//PUBLIC_MESSAGES_ID,
                    createdOnKey: DateFormatter.isoDate.string(from: Date()),
                    isPrivateKey: false
                ]
                
                try await ditto.store.execute(query: "INSERT INTO \(publicRoomsCollectionId) DOCUMENTS (:newDoc) ON ID CONFLICT DO UPDATE", arguments: ["newDoc": newDoc])
            } catch {
                print("Error \(error)")
            }
        }
        
        
    }
}


extension DittoService {
//MARK: Room Archive/Unarchive
    
    func archiveRoom(_ room: Room) {
        if room.isPrivate {
            archivePrivateRoom(room)
        } else {
            archivePublicRoom(room)
        }
    }

    private func archivePrivateRoom(_ room: Room) {
        // 1. remove subscriptions first
        removeSubscriptions(for: room)

        // 2. this operation removes the room from the privateRooms collection and adds to the
        //    archivedPrivateRooms collection, firing the publishers.
        privateStore.archivePrivateRoom(room)
                
        DispatchQueue.main.async { [weak self] in
            // 3. then evict the data (order matters)
            self?.evictPrivateRoom(room)
        }
    }

    private func archivePublicRoom(_ room: Room) {
        // 1. remove subscriptions first
        removeSubscriptions(for: room)
        
        // 2. then evict the data (order matters)
        evictPublicRoom(room)
        
        // 3. stores the room as json-encoded data on disk,
        //    then triggers the archivedPublicRoomsPublisher
        privateStore.archivePublicRoom(room)
        
        DispatchQueue.main.async { [weak self] in
            // 4. causes DittoService to update the @Published publicRoomsPublisher
            self?.updateAllPublicRooms()
        }
    }

    func unarchiveRoom(_ room: Room) {
        if room.isPrivate {
            unarchivePrivateRoom(room)
        } else {
            unarchivePublicRoom(room)
        }
    }
    
    func unarchivePrivateRoom(_ room: Room) {
        addSubscriptions(for: room)
        privateStore.unarchivePrivateRoom(roomId: room.id)
    }

    func unarchivePublicRoom(_ room: Room) {
        privateStore.unarchivePublicRoom(room)
        
        Task {
            do {
                guard let _ = try await ditto.store.execute(query: "SELECT * FROM \(publicRoomsCollectionId) WHERE _id = :id", arguments: ["id": room.id]).items.first else {
                    print("DittoService.\(#function): ERROR - expected non-nil public room for roomId: \(room.id)")
                    return
                }
            } catch {
                print("Error \(error)")
            }
        }
        
        
        addSubscriptions(for: room)
        
        DispatchQueue.main.async { [weak self] in
            self?.updateAllPublicRooms()
        }
    }
    
    func deleteRoom(_ room: Room) {
        // Currently, only deletion of a private room is exposed in the UI
        if room.isPrivate {
            deletePrivateRoom(room)
        } else {
            print("DittoService.\(#function): WARNING - unexpected request to delete PUBLIC room. Not supported")
        }
    }
    
    func deletePrivateRoom(_ room: Room) {
        guard room.collectionId != nil else {
            print("\(#function): ERROR: Expected PrivateRoom collectionId not NIL")
            return
        }
        
        removeSubscriptions(for: room)
        evictPrivateRoom(room)
        
        //Deleting data (remove) is not supported in DQL
        // additionally remove roomDoc, message collection, and collection itself from DB
//        ditto.store[collectionId].findByID(room.id).remove()
//        ditto.store[collectionsKey].findByID(room.messagesId).remove()
//        ditto.store[collectionsKey].findByID(collectionId).remove()

        privateStore.deleteArchivedPrivateRoom(roomId: room.id)
    }
    
    private func evictRoom(_ room: Room) {
        if room.isPrivate {
            evictPrivateRoom(room)
        } else {
            evictPublicRoom(room)
        }
    }

    private func evictPrivateRoom(_ room: Room) {
        guard let collectionId = room.collectionId else {
            print("\(#function): ERROR: Expected PrivateRoom collectionId not NIL")
            return
        }
        
        Task {
            do {
                // evict all messages in collection
                try await ditto.store.execute(query: "EVICT FROM \"\(room.messagesId)\"")
                try await ditto.store.execute(query: "EVICT FROM \(collectionsKey) WHERE _id = :id", arguments: ["id": room.messagesId])
                
                // evict room from collection
                try await ditto.store.execute(query: "EVICT FROM \"\(collectionId)\" WHERE _id = :id", arguments: ["id": room.id])


            } catch {
                print("Error \(error)")
            }
        }
    }
    
    private func evictPublicRoom(_ room: Room) {

        Task {
            do {
                // evict all messages in collection
                try await ditto.store.execute(query: "EVICT FROM \"\(room.messagesId)\"")
                
                // evict the messages collection
                try await ditto.store.execute(query: "EVICT FROM \(collectionsKey) WHERE _id = :id", arguments: ["id": room.messagesId])
                
            } catch {
                print("Error \(error)")
            }
        }

        // We don't need to evict a public room because it will replicate automatically anyway,
        // but room documents are very light-weight.
    }
}

