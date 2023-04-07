///
//  DataManager.swift
//  DittoChat
//
//  Created by Eric Turner on 1/19/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Combine
import DittoSwift
import SwiftUI

protocol LocalDataInterface {
    var acceptLargeImages: Bool { get set }
    var acceptLargeImagesPublisher: AnyPublisher<Bool, Never> { get }
    
    var privateRoomsPublisher: AnyPublisher<[Room], Never> { get }
    func addPrivateRoom(_ room: Room)
    func removePrivateRoom(roomId: String)
    
    var archivedPrivateRoomsPublisher: AnyPublisher<[Room], Never> { get }
    func archivePrivateRoom(_ room: Room)
    @discardableResult func unarchivePrivateRoom(roomId: String) -> Room?
    func deleteArchivedPrivateRoom(roomId: String)
    
    var archivedPublicRoomIDs: [String] { get }
    var archivedPublicRoomsPublisher: AnyPublisher<[Room], Never> { get }
    func archivePublicRoom(_ room: Room)
    func unarchivePublicRoom(_ room: Room)
    
    var currentUserId: String? { get set }
    var currentUserIdPublisher: AnyPublisher<String?, Never> { get }
}

protocol ReplicatingDataInterface {
    var publicRoomsPublisher: CurrentValueSubject<[Room], Never> { get }

    func room(for room: Room) -> Room?
    func createRoom(name: String, isPrivate: Bool)
    func joinPrivateRoom(qrCode: String)
    func roomPublisher(for room: Room) -> AnyPublisher<Room?, Never>

    func archiveRoom(_ room: Room)
    func unarchiveRoom(_ room: Room)
    func deleteRoom(_ room: Room)

    func createMessage(for rooom: Room, text: String)
    func saveEditedMessage(_ message: Message, in room: Room)
    func createImageMessage(for room: Room, image: UIImage, text: String?) async throws
    func messagesPublisher(for room: Room) -> AnyPublisher<[Message], Never>
    func messagePublisher(for msgId: String, in collectionId: String) -> AnyPublisher<Message, Never>
    func attachmentPublisher(
        for token: DittoAttachmentToken,
        in collectionId: String
    ) -> DittoSwift.DittoCollection.FetchAttachmentPublisher
    
    func addUser(_ usr: User)
    func currentUserPublisher() -> AnyPublisher<User?, Never>
    func allUsersPublisher() -> AnyPublisher<[User], Never>
}

class DataManager {
    static let shared = DataManager()
    @Published private(set) var publicRoomsPublisher: AnyPublisher<[Room], Never>
    @Published private(set) var privateRoomsPublisher: AnyPublisher<[Room], Never>

    private var localStore: LocalDataInterface
    private let p2pStore: ReplicatingDataInterface
    
    private init() {
        self.localStore = LocalStoreService()
        self.p2pStore = DittoService(privateStore: localStore)
        self.publicRoomsPublisher = p2pStore.publicRoomsPublisher.eraseToAnyPublisher()
        self.privateRoomsPublisher = localStore.privateRoomsPublisher
    }
}

extension DataManager {
    
    //MARK: Ditto Public Rooms
        
    func room(for room: Room) -> Room? {
        p2pStore.room(for: room)
    }

    func createRoom(name: String, isPrivate: Bool) {
        p2pStore.createRoom(name: name, isPrivate: isPrivate)
    }

    func joinPrivateRoom(qrCode: String) {
        p2pStore.joinPrivateRoom(qrCode: qrCode)
    }

    func roomPublisher(for room: Room) -> AnyPublisher<Room?, Never> {
        p2pStore.roomPublisher(for: room)
    }
    
    func archiveRoom(_ room: Room) {
        p2pStore.archiveRoom(room)
    }
    
    func unarchiveRoom(_ room: Room) {
        p2pStore.unarchiveRoom(room)
    }
    
    func deleteRoom(_ room: Room) {
        p2pStore.deleteRoom(room)
    }

    func archivedPublicRoomsPublisher() -> AnyPublisher<[Room], Never> {
        localStore.archivedPublicRoomsPublisher
    }

    func archivedPrivateRoomsPublisher() -> AnyPublisher<[Room], Never> {
        localStore.archivedPrivateRoomsPublisher
    }
}

extension DataManager {
    //MARK: Messages

    func createMessage(for room: Room, text: String) {
        p2pStore.createMessage(for: room, text: text)
    }

    func createImageMessage(for room: Room, image: UIImage, text: String?) async throws {
        try await p2pStore.createImageMessage(for: room, image: image, text: text)
    }
    
    func saveEditedMessage(_ message: Message, in room: Room) {
        p2pStore.saveEditedMessage(message, in: room)
    }
    
    func messagePublisher(for msgId: String, in collectionId: String) -> AnyPublisher<Message, Never> {
        p2pStore.messagePublisher(for: msgId, in: collectionId)
    }

    func messagesPublisher(for room: Room) -> AnyPublisher<[Message], Never>{
        p2pStore.messagesPublisher(for: room)
    }

    func attachmentPublisher(
        for token: DittoAttachmentToken,
        in collectionId: String
    ) -> DittoSwift.DittoCollection.FetchAttachmentPublisher {
        p2pStore.attachmentPublisher(for: token, in: collectionId)
    }
}

extension DataManager {
    //MARK: Current User
    
    var currentUserId: String? {
        get { localStore.currentUserId }
        set { localStore.currentUserId = newValue }
    }
    
    var currentUserIdPublisher: AnyPublisher<String?, Never> {
        localStore.currentUserIdPublisher
    }
    
    func currentUserPublisher() -> AnyPublisher<User?, Never> {
        p2pStore.currentUserPublisher()
    }

    func allUsersPublisher() -> AnyPublisher<[User], Never> {
        p2pStore.allUsersPublisher()
    }
    
    func addUser(_ usr: User) {
        p2pStore.addUser(usr)
    }

    func saveCurrentUser(firstName: String, lastName: String) {
        if currentUserId == nil {
            let userId = UUID().uuidString
            currentUserId = userId
        }

        assert(currentUserId != nil, "Error: expected currentUserId to not be NIL")

        let user = User(id: currentUserId!, firstName: firstName, lastName: lastName)
        p2pStore.addUser(user)        
    }
}

extension DataManager {
    var sdkVersion: String {
        DittoInstance.shared.ditto.sdkVersion
    }
    
    var appInfo: String {
        let name = Bundle.main.appName
        let version = Bundle.main.appVersion
        let build = Bundle.main.appBuild
        return "\(name) \(version) build \(build)"
    }
}

extension DataManager {    
    var acceptLargeImages: Bool {
        get { localStore.acceptLargeImages }
        set { localStore.acceptLargeImages = newValue }
    }
    
    var acceptLargeImagesPublisher: AnyPublisher<Bool, Never> {
        localStore.acceptLargeImagesPublisher
    }
}
