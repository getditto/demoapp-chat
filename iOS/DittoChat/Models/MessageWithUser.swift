//
//  MessageWithUser.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/20/22.
//

import Foundation

struct MessageWithUser: Identifiable, Hashable, Equatable {
    var message: Message
    var user: User
    var id: String {
        return self.message.id
    }
}
