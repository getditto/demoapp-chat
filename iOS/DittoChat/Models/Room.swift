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
    init(document: DittoDocument) {
        self.id = document[dbIdKey].stringValue
        self.name = document[nameKey].stringValue
        self.messagesId = document[messagesIdKey].stringValue
        self.isPrivate = document[isPrivateKey].boolValue
        self.collectionId = document[collectionIdKey].string
        self.createdBy = document[createdByKey].stringValue
        self.createdOn = DateFormatter.isoDate.date(from: document[createdOnKey].stringValue) ?? Date()
    }
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

