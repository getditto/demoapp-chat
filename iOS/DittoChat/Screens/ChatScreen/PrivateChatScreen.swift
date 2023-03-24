///
//  PrivateChatScreen.swift
//  DittoChat
//
//  Created by Eric Turner on 1/16/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import SwiftUI

struct PrivateChatScreen: View {
    @StateObject var viewModel: ChatScreenVM
    
    init(room: Room) {
        self._viewModel = StateObject(wrappedValue: ChatScreenVM(room: room))
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.messagesWithUsers) { msg in
                            MessageBubbleView(messageWithUser: msg)
                                .id(msg.id)
                                .transition(.slide)
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        scrollToBottom(proxy: proxy)
                    }
                }
                .onChange(of: viewModel.messagesWithUsers.count) { value in
                    withAnimation {
                        proxy.scrollTo(viewModel.messagesWithUsers.last?.id)
                    }
                }
            }
            ChatInputView(
                text: $viewModel.inputText,
                onSendButtonTappedCallback: viewModel.sendMessage
            )
        }
        .sheet(isPresented: $viewModel.presentShareRoomScreen) {
            QRCodeView(
                roomName: viewModel.roomName,
                codeString: viewModel.shareQRCode()
            )
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(viewModel.roomName).font(.headline)
                    if viewModel.room.isPrivate {
                        Text(privateTitleKey).font(.subheadline)
                    }
                }
            }
            if viewModel.room.isPrivate {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.presentShareRoomScreen = true
                    } label: {
                        Image(systemName: qrCodeKey)
                    }
                }
            }
        }
    }
    
    func scrollToBottom(proxy: ScrollViewProxy) {
        proxy.scrollTo(viewModel.messagesWithUsers.last?.id)
    }
}


struct PrivateChatScreen_Previews: PreviewProvider {
    static var previews: some View {
        PrivateChatScreen(
            room: Room(id: "abc", name: "My Room", messagesId: "def", isPrivate: true)
        )
    }
}
