///
//  DittoService.swift
//  DittoChat
//
//  Created by Eric Turner on 2/24/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Combine
import DittoSwift
import SwiftUI

class AuthDelegate: DittoAuthenticationDelegate {
    func authenticationRequired(authenticator: DittoAuthenticator) {
        authenticator.login(
            token: Env.DITTO_AUTH_PASSWORD,
            provider: Env.DITTO_AUTH_PROVIDER
        )  { clientInfo, err in
            print("Login request completed \(err == nil ? "successfully!" : "with error: \(err.debugDescription)")")
        }
    }

    func authenticationExpiringSoon(authenticator: DittoAuthenticator, secondsRemaining: Int64) {
        authenticator.login(
            token: Env.DITTO_AUTH_PASSWORD,
            provider: Env.DITTO_AUTH_PROVIDER
        )  { clientInfo, err in
            print("Login request completed \(err == nil ? "successfully!" : "with error: \(err.debugDescription)")")
        }
    }
}

class DittoInstance {
    static var shared = DittoInstance()
    let ditto: Ditto

    init() {
        // make sure log level is set _before_ starting ditto
        DittoLogger.minimumLogLevel = .debug
        if let logFileURL = LogManager.shared.logFileURL {
            DittoLogger.setLogFileURL(logFileURL)
        }

        let authDelegate = AuthDelegate()
        
        ditto = Ditto(identity:
            .onlineWithAuthentication(
                appID: Env.DITTO_APP_ID,
                authenticationDelegate: authDelegate
            ),
                      persistenceDirectory: self.appDirectory
        )
        
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
    }
    
    var appDirectory: URL! = {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(Env.DITTO_APP_ID, isDirectory: true)
    }()
}

class DittoService: ReplicatingDataInterface {
    @Published var publicRoomsPublisher = CurrentValueSubject<[Room], Never>([])
    @Published fileprivate private(set) var allPublicRooms: [Room] = []
    private var allPublicRoomsCancellable: AnyCancellable = AnyCancellable({})
    private var cancellables = Set<AnyCancellable>()
    
    // private in-memory stores of subscriptions for rooms and messages
    private var privateRoomSubscriptions = [String: DittoSubscription]()
    private var privateRoomMessagesSubscriptions = [String: DittoSubscription]()
    private var publicRoomMessagesSubscriptions = [String: DittoSubscription]()

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
            let mSub = ditto.store[room.messagesId].findAll().subscribe()
            publicRoomMessagesSubscriptions[room.id] = mSub
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
        let rSub = ditto.store[collectionId].findAll().subscribe()
        privateRoomSubscriptions[roomId] = rSub

        let mSub = ditto.store[messagesId].findAll().subscribe()
        privateRoomMessagesSubscriptions[roomId] = mSub
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
                return self.ditto.store.collection(usersKey)
                    .findByID(userId)
                    .singleDocumentLiveQueryPublisher()
                    .compactMap { doc, _ in return doc }
                    .map { User(document: $0) }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func addUser(_ usr: User) {
        _ = try? ditto.store.collection(usersKey)
            .upsert(usr.docDictionary())
    }

    func allUsersPublisher() -> AnyPublisher<[User], Never>  {
        return ditto.store.collection(usersKey).findAll().liveQueryPublisher()
            .map { docs, _ in
                docs.map { User(document: $0) }
            }
            .eraseToAnyPublisher()
    }
}

//MARK: Messages
extension DittoService {
    
    func messagePublisher(for msgId: String, in collectionId: String) -> AnyPublisher<Message, Never> {        
        return ditto.store.collection(collectionId)
            .findByID(msgId)
            .singleDocumentLiveQueryPublisher()
            .compactMap { doc, _ in return doc }
            .map { Message(document: $0) }
            .eraseToAnyPublisher()
    }

    func messagesPublisher(for room: Room) -> AnyPublisher<[Message], Never> {
        return ditto.store.collection(room.messagesId)
            .findAll()
            .sort(createdOnKey, direction: .ascending)
            .liveQueryPublisher()
            .map { docs, _ in
                docs.map { Message(document: $0) }                
            }
            .eraseToAnyPublisher()        
    }
    
    func createMessage(for room: Room, text: String) {
        guard let userId = privateStore.currentUserId else {
            return
        }
        
        guard let room = self.room(for: room) else {
            return
        }
        
        try! ditto.store.collection(room.messagesId)
            .upsert([
                createdOnKey: DateFormatter.isoDate.string(from: Date()),
                roomIdKey: room.id,
                textKey: text,
                userIdKey: userId
            ] as [String: Any?] )
    }
    
    func saveEditedTextMessage(_ message: Message, in room: Room) {
        let _ = ditto.store[room.messagesId].findByID(message.id).update { mutableDoc in
            mutableDoc?[textKey].set(message.text)
        }
    }

    func saveDeletedImageMessage(_ message: Message, in room: Room) {
        let _ = ditto.store[room.messagesId].findByID(message.id).update { mutableDoc in
            mutableDoc?[thumbnailImageTokenKey] = nil
            mutableDoc?[largeImageTokenKey] = nil
            mutableDoc?[textKey].set(message.text)
        }
    }

    // image param expected to be native image size/resolution, from which downsampled thumbnail will be derived
    func createImageMessage(for room: Room, image: UIImage, text: String?) async throws {
        let userId = privateStore.currentUserId ?? createdByUnknownKey
        var nowDate = DateFormatter.isoDate.string(from: Date())
        var fname = attachmentFilename(for: user(for: userId), type: .thumbnailImage, timestamp: nowDate)

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
        
        guard let thumbAttachment = ditto.store[room.messagesId].newAttachment(
            path: tmpStorage.fileURL.path,
            metadata: metadata(for: image, fname: fname, timestamp: nowDate)
        ) else {
            print("Error creating Ditto image attachment from thumbnail jpg data --> Throw")
            throw AttachmentError.createFail
        }
        
        // create new message doc with thumbnail attachment
        let docId = UUID().uuidString
        do {
            try ditto.store[room.messagesId].upsert([
                dbIdKey: docId,
                createdOnKey: nowDate,
                roomIdKey: room.id,
                userIdKey: userId,
                thumbnailImageTokenKey: thumbAttachment
            ])
            
            try await cleanupTmpStorage(tmpStorage.deleteDirectory)
        } catch {
            throw error
        }
        //------------------------------------------------------------------------------------------
        
        //------------------------------------- Large Image  ---------------------------------------
        nowDate = DateFormatter.isoDate.string(from: Date())
        fname = attachmentFilename(for: user(for: userId), type: .largeImage, timestamp: nowDate)

        guard let tmpStorage = try? TemporaryFile(creatingTempDirectoryForFilename: "largeImage.jpg") else {
            print("DittoService.\(#function): Error creating TMP storage directory")
            throw AttachmentError.tmpStorageCreateFail
        }

        guard let _ = try? image.jpegData(compressionQuality: 1.0)?.write(to: tmpStorage.fileURL) else {
            print("Error writing JPG attachment data to file at path: \(tmpStorage.fileURL.path) --> Return")
            throw AttachmentError.tmpStorageWriteFail
        }
        
        guard let largeAttachment = ditto.store[room.messagesId].newAttachment(
            path: tmpStorage.fileURL.path,
            metadata: metadata(for: image, fname: fname, timestamp: nowDate)
        ) else {
            print("Error creating Ditto image attachment from large jpg data --> Throw")
            throw AttachmentError.createFail
        }

        let _ = ditto.store[room.messagesId].findByID(docId).update { mutableDoc in
            mutableDoc?[largeImageTokenKey].set(largeAttachment)
        }
        
        do {
            try await cleanupTmpStorage(tmpStorage.deleteDirectory)
        } catch {
            throw error
        }
    }

    private func metadata(for image:UIImage, fname: String, timestamp: String) -> [String: String] {
        [
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
    ) -> String {
        var fname = self.user(for: privateStore.currentUserId ?? "")?.fullName ?? unknownUserNameKey
        fname = fname.replacingOccurrences(of: " ", with: "-")
        let tmstamp = timestamp.replacingOccurrences(of: ":", with: "-")
        fname += "_\(type.description)" + "_\(tmstamp)" + ext
        
        return fname
    }
    
    private func user(for userId: String) -> User? {
        if let doc = ditto.store[usersKey].findByID(userId).exec() {
            return User(document: doc)
        }
        return nil
    }
    //  --------------------------------------------------------------------------------------------
    
    
    /* DISUSED BECAUSE PROGRESS PUBLISHER BUG (refactored in BubbleViewVM */
    func attachmentPublisher(
        for token: DittoAttachmentToken,
        in collectionId: String
    ) -> DittoSwift.DittoCollection.FetchAttachmentPublisher {
        ditto.store[collectionId].fetchAttachmentPublisher(attachmentToken: token)
    }
}

extension DittoService {
    //MARK: Rooms
    
    private func updateAllPublicRooms() {
        allPublicRoomsCancellable = ditto.store.collection(publicRoomsCollectionId)
            .findAll()
            .sort(createdOnKey, direction: .ascending)
            .liveQueryPublisher()
            .receive(on: DispatchQueue.main)
            .map { docs, _ in
                docs.map { Room(document: $0) }                
            }
            .assign(to: \.allPublicRooms, on: self)
    }
    
    func roomPublisher(for room: Room) -> AnyPublisher<Room?, Never> {
        ditto.store.collection( room.isPrivate ? room.collectionId! : publicRoomsCollectionId )
            .findByID(room.id)
            .singleDocumentLiveQueryPublisher()
            .compactMap { doc, _ in return doc }
            .map { Room(document: $0) }
            .eraseToAnyPublisher()
    }
    
    /// This function returns a room from the Ditto db for the given room. The room argument will be passed from the UI, where
    /// placeholder Room instances are used to display, e.g., archived rooms. In other cases, they are rooms from a publisher of
    /// Room instances,
    func room(for room: Room) -> Room? {
        let collectionId = room.collectionId ?? publicRoomsCollectionId
        
        guard let doc = ditto.store[collectionId].findByID(room.id).exec() else {
            print("DittoService.\(#function): WARNING (except for archived private rooms)" +
                  " - expected non-nil room room.id: \(room.id)"
            )
            return nil
        }
        let room = Room(document: doc)
        return room
    }

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
        
        try! ditto.store[collectionId].upsert(
            room.docDictionary()
        )

        if isPrivate {
            privateStore.addPrivateRoom(room)
        }
    }
    
    func joinPrivateRoom(qrCode: String) {
        let parts = qrCode.split(separator: "\n")
        guard parts.count == 3 else {
            print("DittoService.\(#function): Error - expected 3 parts to QR code: \(qrCode) --> RETURN")
            return
        }
        // parse qrCode for roomId, collectionId, messagesId
        let roomId = String(parts[0])
        let collectionId = String(parts[1])
        let messagesId = String(parts[2])

        addPrivateRoomSubscriptions(
            roomId: roomId,
            collectionId: collectionId,
            messagesId: messagesId
        )

        joinRoomQuery = ditto.store.collection(collectionId).findByID(roomId).observeLocal { [unowned self] doc, _ in
            if let roomDoc = doc  {
                let room = Room(document: roomDoc)
                self.privateStore.addPrivateRoom(room)
                
                // NOTE: the core ditto engine retains the local observer once it's initialized, and
                // here the observer MUST be stopped after the add operation or else every
                // subsequent update to this document, local or remote, will fire this closure.
                self.joinRoomQuery?.stop()
                self.joinRoomQuery = nil
            }
        }
    }
    
    private func createDefaultPublicRoom() {
        // Only create default Public room if user does not yet exist, i.e. first launch
        if privateStore.currentUserId != nil {
//        if allPublicRooms.count > 0 {
            return
        }
        
        // Create default Public room with pre-configured id, messagesId
        try! ditto.store.collection(publicRoomsCollectionId)
            .upsert([
                dbIdKey: publicKey,
                nameKey: publicRoomTitleKey,
                collectionIdKey: publicRoomsCollectionId,
                messagesIdKey: publicMessagesIdKey,//PUBLIC_MESSAGES_ID,
                createdOnKey: DateFormatter.isoDate.string(from: Date()),
                isPrivateKey: false
            ] as [String: Any?] )
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
        
        guard let _ = ditto.store[publicRoomsCollectionId].findByID(room.id).exec() else {
            print("DittoService.\(#function): ERROR - expected non-nil public room for roomId: \(room.id)")
            return
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
        guard let collectionId = room.collectionId else {
            print("\(#function): ERROR: Expected PrivateRoom collectionId not NIL")
            return
        }
        
        removeSubscriptions(for: room)
        evictPrivateRoom(room)
        
        // additionally remove roomDoc, message collection, and collection itself from DB
        ditto.store[collectionId].findByID(room.id).remove()
        ditto.store[collectionsKey].findByID(room.messagesId).remove()
        ditto.store[collectionsKey].findByID(collectionId).remove()

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
        
        // evict all messages in collection
        ditto.store[room.messagesId].findAll().evict()
        ditto.store[collectionsKey].findByID(room.messagesId).evict()
        
        // evict room from collection
        ditto.store[collectionId].findByID(room.id).evict()
    }
    
    private func evictPublicRoom(_ room: Room) {
        // evict all messages in collection
        ditto.store[room.messagesId].findAll().evict()
        
        // evict the messages collection
        ditto.store[collectionsKey].findByID(room.messagesId).evict()

        // We don't need to evict a public room because it will replicate automatically anyway,
        // but room documents are very light-weight.
    }
}

