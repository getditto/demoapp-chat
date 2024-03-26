///
//  PrivateRoom.swift
//  DittoChat
//
//  Created by Eric Turner on 1/12/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import DittoSwift
import Foundation

extension Room: Codable {}

struct Room: Identifiable, Hashable, Equatable {
    let id: String
    let name: String
    let messagesId: String
    private(set) var isPrivate: Bool
    let collectionId: String?
    let createdBy: String
    let createdOn: Date
}

extension Room {
    init(
        id: String,
        name: String,
        messagesId: String,
        isPrivate: Bool,
        collectionId: String? = nil,
        createdBy: String? = nil,
        createdOn: Date? = nil
    ) {
        let userId = DataManager.shared.currentUserId ?? createdByUnknownKey
        self.id = id
        self.name = name
        self.messagesId = messagesId
        self.isPrivate = isPrivate
        self.collectionId = collectionId
        self.createdBy = createdBy ?? userId
        self.createdOn = createdOn ?? Date()
    }
}

extension Room {
    func docDictionary() -> [String: Any?] {
        [
            dbIdKey: id,
            nameKey: name,
            messagesIdKey: messagesId,
            isPrivateKey: isPrivate,
            collectionIdKey: collectionId,
            createdByKey: createdBy,
            createdOnKey: DateFormatter.isoDate.string(from: createdOn),
        ]
    }
}

extension Room {
    // This "dummy" object is a Room object used by DittoChatApp.swift
    // to initialize a basic chat mode ChatScreen as root view
    static var basicChatDummy: Room {
        Room(
            id: publicKey,
            name: publicRoomTitleKey,
            messagesId: publicMessagesIdKey,
            isPrivate: false
        )
    }
}

extension Room: DittoDecodable {
    init(value: [String: Any?]) {
        self.id = value[dbIdKey] as? String ?? ""
        self.name = value[nameKey] as? String ?? ""
        self.messagesId = value[messagesIdKey] as? String ?? ""
        self.isPrivate = value[isPrivateKey] as? Bool ?? false
        self.collectionId = value[collectionIdKey] as? String
        self.createdBy = value[createdByKey] as? String ?? ""
        let dateString = value[createdOnKey] as? String ?? ""
        self.createdOn = DateFormatter.isoDate.date(from: dateString) ?? Date()
    }
}

