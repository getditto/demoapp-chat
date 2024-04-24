//
//  RoomsListRowItem.swift
//  DittoChat
//
//  Created by Eric Turner on 2/17/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import SwiftUI

struct RoomsListRowItem: View {
    @ObservedObject var viewModel: RoomsListRowItemViewModel

    init(room: Room) {
        self.viewModel = RoomsListRowItemViewModel(room: room)
    }

    var body: some View {
        HStack {
            if viewModel.subscribedTo() {
                Text(viewModel.room.name)
                    .bold()
                    .italic()
            } else {
                Text(viewModel.room.name)
            }
            Spacer()
            if viewModel.subscribedTo(), viewModel.unreadMessagesCount() != 0 {
                Text(viewModel.unreadMessagesCount().description)
                    .padding(.horizontal)
                    .background(.gray)
                    .clipShape(.capsule)
            }
            if viewModel.mentionsCount() != 0 {
                Text(viewModel.mentionsCount().description)
                    .padding(.horizontal)
                    .background(.gray)
                    .clipShape(.capsule)
            }
        }
    }
}

class RoomsListRowItemViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentUser: ChatUser?
    @Published var room: Room

    init(room: Room) {
        self.room = room

        DataManager.shared.messagesPublisher(for: room)
            .assign(to: &$messages)

        DataManager.shared.currentUserPublisher()
            .assign(to: &$currentUser)
    }


    func unreadMessagesCount() -> Int {
        guard let currentUser,
              subscribedTo(),
              let keyValue = currentUser.subscriptions[room.id],
              let date = keyValue else {
            return 0
        }

        let firstIndex = messages.firstIndex { message in
            message.createdOn > date
        }

        if let firstIndex {
            return messages.count - firstIndex
        }

        return 0
    }

    func subscribedTo() -> Bool {
        guard let currentUser,
              let keyValue = currentUser.subscriptions[room.id],
              let date = keyValue else {
            return false
        }

        return true
    }

    func mentionsCount() -> Int {
        guard let currentUser else {
            return 0
        }

        return currentUser.mentions[room.id]?.count ?? 0
    }
}

#if DEBUG
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
#endif
