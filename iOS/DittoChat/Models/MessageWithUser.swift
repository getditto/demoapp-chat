//
//  MessageWithUser.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/20/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//

import Foundation

struct MessageWithUser: Identifiable, Hashable, Equatable {
    var message: Message
    var user: ChatUser
    var id: String {
        return self.message.id
    }
}
