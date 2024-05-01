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
    case edit, deleteImage, deleteText, presentAttachment
}

class ChatScreenVM: ObservableObject {
    @Published var inputText: String = ""
    @Published var roomName: String = ""
    @Published var messagesWithUsers = [MessageWithUser]()
    var room: Room
    
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var presentAttachmentView = false
    var attachmentMessage: Message?
    
    @Published var presentEditingView = false
    @Published var isEditing = false
    @Published var keyboardStatus: KeyboardChangeEvent = .unchanged
    var editMsgId: String?
        
    @Published var presentShareRoomScreen = false
    
    // Basic chat mode
    @Published var presentProfileScreen: Bool = false
    @Published var presentSettingsView = false
    var isBasicChatScreen: Bool {
        DataManager.shared.basicChat && room.id == publicKey
    }

    init(room: Room) {
        // In Basic chat mode, display profile screen if user is nil (first launch)
        if room.id == publicKey && DataManager.shared.basicChat {
            self.presentProfileScreen = DataManager.shared.currentUserId == nil
        }
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
                if let room = room { self.room = room }
                return room?.name ?? ""
            }
            .assign(to: &$roomName)
        
        Publishers.keyboardStatus
            .assign(to: &$keyboardStatus)
    }
    
    func sendMessage() {
        // only allow non-empty string messages
        guard !inputText.isEmpty else { return }

        Task {
            await DataManager.shared.createMessage(for: room, text: inputText)
            await MainActor.run {
                inputText = ""
            }
        }
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
        case .presentAttachment:
            presentAttachment(msg)
        }
    }

    func editMessageCallback(_ msg: Message) {
        editMsgId = msg.id
        isEditing = true
        presentEditingView = true
    }
    
    func cancelEditCallback() {
        cleanupEdit()
    }
    
    func cleanupEdit() {
        editMsgId = nil
        isEditing = false
        presentEditingView = false
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
        cleanupEdit()
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
    
    func presentAttachment(_ msg: Message) {
        attachmentMessage = msg
        presentAttachmentView = true
    }
    
    func cleanupAttachmentAttribs() {
        attachmentMessage = nil
    }

    // private room
    func shareQRCode() -> String? {
        if let collectionId = room.collectionId {
            return "\(room.id)\n\(collectionId)\n\(room.messagesId)\n\(room.name)\n\(room.isPrivate)\n\(room.createdBy)\n\(room.createdOn)"
        }
        return nil
    }
}



