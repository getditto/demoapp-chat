///
//  ChatScreen.swift
//  DittoChat
//
//  Created by Eric Turner on 02/24/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import SwiftUI
import PhotosUI
import SwiftUI

struct ChatScreen: View {
    @StateObject var viewModel: ChatScreenVM
    @EnvironmentObject var errorHandler: ErrorHandler

    init(room: Room) {
        self._viewModel = StateObject(wrappedValue: ChatScreenVM(room: room))
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.messagesWithUsers) { usrMsg in
                            MessageBubbleView(
                                messageWithUser: usrMsg,
                                messagesId: viewModel.room.messagesId,
                                messageOpCallback: viewModel.messageOperationCallback
                            )
                            .id(usrMsg.message.id)
                            .transition(.slide)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    DispatchQueue.main.async {
                        scrollToBottom(proxy: proxy)
                    }
                }
                .onChange(of: viewModel.messagesWithUsers.count) { value in
                    DispatchQueue.main.async {
                        withAnimation {
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }
                .onChange(of: viewModel.keyboardStatus) { status in
                    guard !viewModel.presentEditingView else { return }
                    if status == .willShow || status == .willHide { return }
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
        .listStyle(.inset)
        .navigationTitle(viewModel.roomName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.presentShareRoomScreen) {
            if let codeStr = viewModel.shareQRCode() {
                QRCodeView(
                    roomName: viewModel.roomName,
                    codeString: codeStr
                )
            } else {
                NavigationView {
                    GeneralErrorView(message: AppError.qrCodeFail.localizedDescription)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if viewModel.room.isPrivate {
                    Button {
                        viewModel.presentShareRoomScreen = true
                    } label: {
                        Image(systemName: qrCodeKey)
                    }
                }

                PhotosPicker(selection: $viewModel.selectedItem,
                             matching: .images,
                             photoLibrary: .shared()
                ) {
                    Image(systemName: shareImageIconKey)
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.borderless)
                .onChange(of: viewModel.selectedItem) { newValue in
                    Task {
                        do {
                            let imageData = try await newValue?.loadTransferable(type: Data.self)
                            
                            if let image = UIImage(data: imageData ?? Data()) {
                                viewModel.selectedImage = image
                                
                                do {
                                    try await viewModel.sendImageMessage()
                                } catch {
                                    self.errorHandler.handle(error: error)
                                }
                            }
                        } catch {
                            self.errorHandler.handle(error: AttachmentError.iCloudLibraryImageFail)
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.presentEditingView) {
            if let msgsUsers = try? viewModel.editMessagesWithUsers() {
                NavigationView {
                    MessageEditView(
                        msgsUsers,
                        roomName: viewModel.roomName,
                        editFunc: viewModel.saveEditedTextMessage
                    )
                }
            } else {
                EmptyView()
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
