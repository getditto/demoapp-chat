//
//  Message.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/19/22.
//

import DittoSwift
import Foundation

extension Message: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Message: Identifiable, Equatable {
    var id: String
    var createdOn: Date
    var roomId: String
    var text: String
    var userId: String
    var largeImageToken: [String: Any]?
    var thumbnailImageToken: [String: Any]?

    var isImageMessage: Bool {
        thumbnailImageToken != nil || largeImageToken != nil
    }

    // FIXME: Excluding attachment tokens from equality because Any is not equatable
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id &&
        lhs.createdOn == rhs.createdOn &&
        lhs.roomId == rhs.roomId &&
        lhs.text == rhs.text &&
        lhs.userId == rhs.userId &&
        lhs.isImageMessage == rhs.isImageMessage
    }
}

extension Message {
    init(
        id: String? = nil,
        createdOn: Date? = nil,
        roomId: String,
        text: String? = nil,
        userId: String? = nil,
        largeImageToken: [String: Any]? = nil,
        thumbnailImageToken: [String: Any]? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.createdOn = createdOn ?? Date()
        self.roomId = roomId
        self.text = text ?? ""
        self.userId = DataManager.shared.currentUserId ?? createdByUnknownKey
        self.largeImageToken = largeImageToken
        self.thumbnailImageToken = thumbnailImageToken
    }
}

extension Message {
    func docDictionary() -> [String: Any?] {
        [
            dbIdKey: id,
            createdOnKey: DateFormatter.isoDate.string(from: createdOn),
            roomIdKey: roomId,
            textKey: text,
            userIdKey: userId,
            largeImageTokenKey: largeImageToken,
            thumbnailImageTokenKey: thumbnailImageToken
        ]
    }
}

extension Message: DittoDecodable {
    init(value: [String: Any?]) {
        print("Init with id: \(String(describing: value[dbIdKey] as? String))")
        if let id = value[dbIdKey] as? String {
            self.id = id
        } else {
            self.id = ""
        }

        if let createdOnString = value[createdOnKey] as? String,
           let createdOnDate = DateFormatter.isoDate.date(from: createdOnString) {
            self.createdOn = createdOnDate
        } else {
            self.createdOn = Date()
        }

        if let roomId = value[roomIdKey] as? String {
            self.roomId = roomId
        } else {
            self.roomId = ""
        }

        if let text = value[textKey] as? String {
            self.text = text
        } else {
            self.text = ""
        }

        if let userId = value[userIdKey] as? String {
            self.userId = userId
        } else {
            self.userId = DataManager.shared.currentUserId ?? createdByUnknownKey
        }

        // Attachment tokens are now a sub-dictionary under the key the attachment was saved at.
        self.largeImageToken = value[largeImageTokenKey] as? [String: Any]
        self.thumbnailImageToken = value[thumbnailImageTokenKey] as? [String: Any]
        print("Checking thumbnailToken value \(String(describing: value[thumbnailImageTokenKey] as? [String: Any]))")

    }
}
