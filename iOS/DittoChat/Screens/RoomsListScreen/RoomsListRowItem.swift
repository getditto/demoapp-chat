///
//  RoomsListRowItem.swift
//  DittoChat
//
//  Created by Eric Turner on 2/17/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import SwiftUI

struct RoomsListRowItem: View {
    let room: Room
    
    var body: some View {
        Text(room.name)
    }
}

struct RoomsListRowItem_Previews: PreviewProvider {
    static var previews: some View {
        RoomsListRowItem(
            room: Room(
                id: "id123",
                name: "My Room",
                messagesId: "msgId123",
                isPrivate: false
            )
        )
    }
}
