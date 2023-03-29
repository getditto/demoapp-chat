///
//  PrivateChatScreen.swift
//  DittoChat
//
//  Created by Eric Turner on 1/16/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import PhotosUI
import SwiftUI

struct PrivateChatScreen: View {
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
                        ForEach(viewModel.messagesWithUsers) { msg in
                            MessageBubbleView(
                                messageWithUser: msg,
                                messagesId: viewModel.room.messagesId
                            )
                                .id(msg.id)
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
//        .sheet(isPresented: $viewModel.showDocPicker) {
//            DocumentPickerView()
//        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    viewModel.presentShareRoomScreen = true
                } label: {
                    Image(systemName: qrCodeKey)
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
