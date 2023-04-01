///
//  MessageEditView.swift
//  DittoChat
//
//  Created by Eric Turner on 3/30/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Combine
import SwiftUI

class MessageEditVM: ObservableObject {
    @Published var editText: String
    @Published var messagesWithUsers: ArraySlice<MessageWithUser>
    @Published var keyboardStatus: KeyboardChangeEvent = .unchanged
    var editUsrMsg: MessageWithUser
    let saveEditCallback: (Message) -> Void
    
    init(
        _ msgsUsers: (editUsrMsg: MessageWithUser, chats: ArraySlice<MessageWithUser>),
        editFunc: @escaping (Message) -> Void)
    {
        self.editUsrMsg = msgsUsers.editUsrMsg
        self.editText = editUsrMsg.message.text
        self.messagesWithUsers = msgsUsers.chats
        self.saveEditCallback = editFunc

        Publishers.keyboardStatus
            .assign(to: &$keyboardStatus)
    }
    
    var editMessage: Message {
        editUsrMsg.message
    }
    
    func editCallback() {
        editUsrMsg.message.text = editText
    }
    
    func saveEdit() {
        if editMessage.text == editText { return } // no edit change
        editUsrMsg.message.text = editText
        saveEditCallback(editUsrMsg.message)
    }
}

struct MessageEditView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: MessageEditVM
    let roomName: String
    
    
    init(
        _ msgsUsers: (editUsrMsg: MessageWithUser, chats: ArraySlice<MessageWithUser>),
        roomName: String,
        editFunc: @escaping (Message) -> Void
    ) {
        self._viewModel = StateObject(
            wrappedValue: MessageEditVM(msgsUsers, editFunc: editFunc)
        )
        self.roomName = roomName
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.messagesWithUsers) { usrMsg in
                            bubbleView(for: usrMsg)
                                .transition(.slide)
                        }
                    }
                    
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    DispatchQueue.main.async {
                        withAnimation {
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }
                .onChange(of: viewModel.editText) { value in
                    withAnimation {
                        scrollToBottom(proxy: proxy)
                    }
                }
                .onChange(of: viewModel.keyboardStatus) { status in
                    if status == .willShow || status == .willHide { return }
                    withAnimation {
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
            
            Spacer()
            
            ChatInputView(
                text: $viewModel.editText,
                onSendButtonTappedCallback: viewModel.saveEdit
                
            )
        }
        .listStyle(.inset)
        .navigationTitle(roomName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                .buttonStyle(.borderless)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.saveEdit()
                } label: {
                    Text("Save")
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    @ViewBuilder
    func bubbleView(for usrMsg: MessageWithUser) -> some View {
        if usrMsg.id != viewModel.editUsrMsg.id {
            MessageBubbleView(
                messageWithUser: usrMsg,
                messagesId: "placeholder_in_MessageEditView"
            )
            .id(usrMsg.id)
        } else {
            EditMessageBubbleView(viewModel: viewModel)
                .id(viewModel.editUsrMsg.id)
        }
    }
    
    func saveEditedText(_ text: String) {
        viewModel.editUsrMsg.message.text = text
    }

    func scrollToBottom(proxy: ScrollViewProxy) {
        proxy.scrollTo(viewModel.messagesWithUsers.last?.id)
    }
}

//struct MessageEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageEditView()
//    }
//}
