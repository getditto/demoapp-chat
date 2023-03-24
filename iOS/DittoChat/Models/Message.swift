//
//  Message.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/19/22.
//

import DittoSwift
import Foundation

struct Message: Identifiable, Equatable, Hashable {
    var id: String
    var createdOn: Date
    var roomId: String
    var text: String
    var userId: String
}

extension Message {
    init(document: DittoDocument) {
        self.id = document[dbIdKey].stringValue
        self.createdOn = DateFormatter.isoDate.date(from: document[createdOnKey].stringValue) ?? Date()
        self.roomId = document[roomIdKey].stringValue
        self.text = document[textKey].stringValue
        self.userId = document[userIdKey].stringValue
    }
}
