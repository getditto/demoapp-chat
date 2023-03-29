///
//  PrivateChatScreenVM.swift
//  DittoChat
//
//  Created by Eric Turner on 2/20/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Combine
import PhotosUI
import SwiftUI

class ChatScreenVM: ObservableObject {
    @Published var inputText: String = ""
    @Published var roomName: String = ""
    @Published var messagesWithUsers = [MessageWithUser]()
    @Published var presentShareRoomScreen = false
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    let room: Room

    init(room: Room) {
        self.room = room

        let users = DataManager.shared.allUsersPublisher()
        let messages = DataManager.shared.messagesPublisher(for: room)

        messages.combineLatest(users)
            .map { messages, users -> [MessageWithUser] in
                var messagesWithUsers = [MessageWithUser]()
                for message in messages {
                    let user = users.first(where: { $0.id == message.userId }) ?? User.unknownUser()
                    messagesWithUsers.append(MessageWithUser(message: message, user: user))
                }
                return messagesWithUsers
            }
            .assign(to: &$messagesWithUsers)

        DataManager.shared.roomPublisher(for: room)
            .map { room -> String in
                return room?.name ?? ""
            }
            .assign(to: &$roomName)
    }

    func sendMessage() {
        // only allow non-empty string messages
        guard !inputText.isEmpty else { return }

        DataManager.shared.createMessage(for: room, text: inputText)
        
        inputText = ""
    }
    
    func sendImageMessage() async throws {
        guard let image = selectedImage else {
            throw AttachmentError.libraryImageFail
        }
        
        do {
            try await DataManager.shared.createImageMessage(for: room, image: image, text: inputText)
            
        } catch {
            print("Caught error: \(error.localizedDescription)")
            throw error
        }
        
        await MainActor.run {
            inputText = ""
            selectedItem = nil
            selectedImage = nil
        }
    }
    
    // private room
    func shareQRCode() -> String? {
        if let collectionId = room.collectionId {
            return "\(room.id)\n\(collectionId)\n\(room.messagesId)"
        }
        return nil
    }
}
