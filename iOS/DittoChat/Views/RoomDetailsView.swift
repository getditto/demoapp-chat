//
//  RoomDetailsView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/21/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import SwiftUI

struct RoomDetailsView: View {
    let room: Room
    @ObservedObject var viewModel: SettingsScreenVM

    var body: some View {
        roomViewDetails(room)
        Spacer()
    }

    @ViewBuilder
    func roomViewDetails(_ room: Room) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            let user = user(for: room.createdBy)
            Group {
                HStack {
                    Text(nameLabelKey).opacity(0.5)
                    Text(room.name)
                }
                HStack {
                    Text(createdByLabelKey).opacity(0.5)
                    Text(user.fullName)
                }
                HStack {
                    Text(createdOnLabelKey).opacity(0.5)
                    Text(DateFormatter.isoDate.string(from: room.createdOn))
                }
                HStack {
                    Text(privateLabelKey).opacity(0.5)
                    Text(room.isPrivate ? trueKey : falseKey)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(messagesIdLabelKey).opacity(0.5)
                        Text(room.messagesId)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(collectionIdLabelKey).opacity(0.5)
                        Text(collectionIdString(room.collectionId))
                    }
                }
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

                Spacer()
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
    }

    private func user(for userId: String) -> ChatUser {
        if let user = viewModel.users.first(where: { $0.id == userId }) {
            return user
        }
        return ChatUser.unknownUser()
    }

    private func collectionIdString(_ str: String?) -> String {
        guard let str = str else {
            return room.isPrivate ? notAvailableLabelKey : publicRoomsCollectionId
        }
        return str.isEmpty ? notAvailableLabelKey : str
    }
}

//#if DEBUG
// struct RoomDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomDetailView()
//    }
// }
//#endif
