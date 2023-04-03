///
//  ChatScreenVM.swift
//  DittoChat
//
//  Created by Eric Turner on 2/20/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Combine
import PhotosUI
import SwiftUI

enum MessageOperation {
    case edit, deleteImage, deleteText
}

class ChatScreenVM: ObservableObject {
    @Published var inputText: String = ""
    @Published var roomName: String = ""
    @Published var messagesWithUsers = [MessageWithUser]()
    @Published var presentShareRoomScreen = false
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var presentEditingView = false
    @Published var keyboardStatus: KeyboardChangeEvent = .unchanged
    let room: Room
    var editMsgId: String?

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
        
        Publishers.keyboardStatus
            .assign(to: &$keyboardStatus)
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
    
    func messageOperationCallback(_ op: MessageOperation, msg: Message) {
        switch op {
        case .edit:
            editMessageCallback(msg)
        case .deleteImage:
            deleteImageMessage(msg)
        case .deleteText:
            deleteTextMessage(msg)
        }
    }

    func editMessageCallback(_ msg: Message) {
        editMsgId = msg.id
        presentEditingView = true
    }

    func editMessagesWithUsers() throws -> (editUsrMsg: MessageWithUser, chats: ArraySlice<MessageWithUser>) {
        guard let msgIdx = messagesWithUsers.firstIndex(where: { $0.id == editMsgId }) else {
            throw AppError.unknown("could not find message with id: \(editMsgId ?? "nil")")
        }
        let usrMsg = messagesWithUsers[msgIdx]
        let chats = messagesWithUsers.prefix(through: msgIdx)
        return (editUsrMsg: usrMsg, chats: chats)
    }
    
    func saveEditedTextMessage(_ msg: Message) {
        if msg.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return deleteTextMessage(msg)
        }
        DataManager.shared.saveEditedTextMessage(msg, in: room)
        editMsgId = nil
        presentEditingView = false
    }
    
    func deleteTextMessage(_ msg: Message) {
        var editedMsg = msg
        editedMsg.text = deletedTextMessageKey
        saveEditedTextMessage(editedMsg)
    }
    
    func deleteImageMessage(_ msg: Message) {
        var editedMsg = msg
        editedMsg.text = deletedImageMessageKey
        editedMsg.thumbnailImageToken = nil
        editedMsg.largeImageToken = nil
        DataManager.shared.saveDeletedImageMessage(editedMsg, in: room)
    }

    // private room
    func shareQRCode() -> String? {
        if let collectionId = room.collectionId {
            return "\(room.id)\n\(collectionId)\n\(room.messagesId)"
        }
        return nil
    }
}
