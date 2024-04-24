//
//  DataManager.swift
//  DittoChat
//
//  Created by Eric Turner on 1/19/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import Combine
import DittoSwift
import SwiftUI

protocol LocalDataInterface {
    var acceptLargeImages: Bool { get set }
    var acceptLargeImagesPublisher: AnyPublisher<Bool, Never> { get }

    var privateRoomsPublisher: AnyPublisher<[Room], Never> { get }
    func addPrivateRoom(_ room: Room)

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

    var basicChat: Bool { get set }
    var basicChatPublisher: AnyPublisher<Bool, Never> { get }
}

protocol ReplicatingDataInterface {
    var publicRoomsPublisher: CurrentValueSubject<[Room], Never> { get }

    func room(for room: Room) -> Room?
    func findPublicRoomById(id: String) -> Room?
    func createRoom(name: String, isPrivate: Bool) -> DittoDocumentID?
    func joinPrivateRoom(qrCode: String)
    func roomPublisher(for room: Room) -> AnyPublisher<Room?, Never>

    func archiveRoom(_ room: Room)
    func unarchiveRoom(_ room: Room)
    func deleteRoom(_ room: Room)

    func createMessage(for rooom: Room, text: String)
    func saveEditedTextMessage(_ message: Message, in room: Room)
    func saveDeletedImageMessage(_ message: Message, in room: Room)
    func createImageMessage(for room: Room, image: UIImage, text: String?) async throws
    func messagesPublisher(for room: Room) -> AnyPublisher<[Message], Never>
    func messagePublisher(for msgId: String, in collectionId: String) -> AnyPublisher<Message, Never>
    func attachmentPublisher(
        for token: DittoAttachmentToken,
        in collectionId: String
    ) -> DittoSwift.DittoCollection.FetchAttachmentPublisher

    func addUser(_ usr: ChatUser)
    func updateUser(withId id: String,
                    firstName: String?,
                    lastName: String?,
                    subscriptions: [String: Date?]?,
                    mentions: [String: [String]]?)
    func currentUserPublisher() -> AnyPublisher<ChatUser?, Never>
    func allUsersPublisher() -> AnyPublisher<[ChatUser], Never>
}

public class DataManager {
    public static let shared = DataManager()
    @Published public private(set) var publicRoomsPublisher: AnyPublisher<[Room], Never>
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
    // MARK: Ditto Public Rooms

    func room(for room: Room) -> Room? {
        p2pStore.room(for: room)
    }

    public func findPublicRoomById(id: String) -> Room? {
        p2pStore.findPublicRoomById(id: id)
    }

    public func createRoom(name: String, isPrivate: Bool) -> DittoDocumentID? {
        return p2pStore.createRoom(name: name, isPrivate: isPrivate)
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

    public func deleteRoom(_ room: Room) {
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
    // MARK: Messages

    func createMessage(for room: Room, text: String) {
        p2pStore.createMessage(for: room, text: text)
    }

    func createImageMessage(for room: Room, image: UIImage, text: String?) async throws {
        try await p2pStore.createImageMessage(for: room, image: image, text: text)
    }

    func saveEditedTextMessage(_ message: Message, in room: Room) {
        p2pStore.saveEditedTextMessage(message, in: room)
    }

    func saveDeletedImageMessage(_ message: Message, in room: Room) {
        p2pStore.saveDeletedImageMessage(message, in: room)
    }

    func messagePublisher(for msgId: String, in collectionId: String) -> AnyPublisher<Message, Never> {
        p2pStore.messagePublisher(for: msgId, in: collectionId)
    }

    func messagesPublisher(for room: Room) -> AnyPublisher<[Message], Never> {
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
    // MARK: Current User

    public var currentUserId: String? {
        get { localStore.currentUserId }
        set { localStore.currentUserId = newValue }
    }

    var currentUserIdPublisher: AnyPublisher<String?, Never> {
        localStore.currentUserIdPublisher
    }

    func currentUserPublisher() -> AnyPublisher<ChatUser?, Never> {
        p2pStore.currentUserPublisher()
    }

    public func allUsersPublisher() -> AnyPublisher<[ChatUser], Never> {
        p2pStore.allUsersPublisher()
    }

    func addUser(_ usr: ChatUser) {
        p2pStore.addUser(usr)
    }

    func updateUser(withId id: String, firstName: String?, lastName: String?, subscriptions: [String: Date?]?, mentions: [String: [String]]?) {
        p2pStore.updateUser(withId: id, firstName: firstName, lastName: lastName, subscriptions: subscriptions, mentions: mentions)
    }

    public func saveCurrentUser(firstName: String, lastName: String) {
        if currentUserId == nil {
            let userId = UUID().uuidString
            currentUserId = userId
        }

        assert(currentUserId != nil, "Error: expected currentUserId to not be NIL")

        let user = ChatUser(id: currentUserId!, firstName: firstName, lastName: lastName, subscriptions: [:], mentions: [:])
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

public extension DataManager {
    var basicChat: Bool {
        get { localStore.basicChat }
        set { localStore.basicChat = newValue }
    }

    var basicChatPublisher: AnyPublisher<Bool, Never> {
        get { localStore.basicChatPublisher }
    }
}
