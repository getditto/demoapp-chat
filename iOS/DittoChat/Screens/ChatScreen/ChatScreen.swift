///
//  PrivateChatScreen.swift
//  DittoChat
//
//  Created by Eric Turner on 02/24/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import SwiftUI

struct ChatScreen: View {
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
                        scrollToBottom(proxy: proxy)
                    }
                }
            }
            ChatInputView(
                text: $viewModel.inputText,
                onSendButtonTappedCallback: viewModel.sendMessage
            )
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(viewModel.roomName)
                }
            }
        }
    }
    
    func scrollToBottom(proxy: ScrollViewProxy) {
        proxy.scrollTo(viewModel.messagesWithUsers.last?.id)
    }
}

#if DEBUG
struct ChatScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChatScreen(room: Room(id: "abc", name: "My Room", messagesId: "def", isPrivate: true))
    }
}
#endif
