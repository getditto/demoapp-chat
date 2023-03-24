//
//  RoomsListScreen.swift
//  DittoChat
//
//  Created by Eric Turner on 2/17/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import SwiftUI

struct RoomsListScreen: View {
    @ObservedObject var viewModel = RoomsListScreenVM()

    var body: some View {
        List {
            if let defaultPublicRoom = viewModel.defaultPublicRoom {
                Section(openPublicRoomTitleKey) {
                    NavigationLink(value: defaultPublicRoom) {
                        RoomsListRowItem(room: defaultPublicRoom)
                    }
                }
            }
            Section( viewModel.publicRooms.count > 0 ? publicRoomsTitleKey : "" ) {
                ForEach(viewModel.publicRooms) { room in
                    NavigationLink(value: room) {
                        RoomsListRowItem(room: room)
                    }                    
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(hideTitleKey) {
                            viewModel.archiveRoom(room)
                        }
                        .tint(.red)
                    }
                }
            }

            Section( viewModel.privateRooms.count > 0 ? privateRoomsTitleKey : "" ) {
                ForEach(viewModel.privateRooms) { room in
                    NavigationLink(value: room) {
                        RoomsListRowItem(room: room)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(leaveTitleKey) {
                            viewModel.archiveRoom(room)
                        }
                        .tint(.red)
                    }
                }
            }
        }
        .navigationDestination(for: Room.self) { room in
            if room.isPrivate {
                PrivateChatScreen(room: room)
            } else {
                ChatScreen(room: room)
            }
        }
        .sheet(isPresented: $viewModel.presentProfileScreen) {
            ProfileScreen()
        }
        .sheet(isPresented: $viewModel.presentScannerView) {
            ScannerView(
                successAction: { code in
                    viewModel.joinPrivateRoom(code: code)
                }
            )
        }
        .sheet(isPresented: $viewModel.presentCreateRoomScreen) {
            RoomEditScreen()
        }
        .sheet(isPresented: $viewModel.presentSettingsView) {
            SettingsScreen()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading ) {
                Button {
                    viewModel.profileButtonAction()
                } label: {
                    Image(systemName: personCircleKey)
                }
                Button {
                    viewModel.presentSettingsView = true
                } label: {
                    Image(systemName: gearShapeKey)
                }
            }
            ToolbarItemGroup(placement: .principal ) {
                Text(appTitleKey)
                    .fontWeight(.bold)
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    viewModel.scanButtonAction()
                } label: {
                    Label(scanPrivateRoomTitleKey, systemImage: qrCodeViewfinderKey)
                }
                Button {
                    viewModel.createRoomButtonAction()
                } label: {
                    Label(newRoomTitleKey, systemImage: plusMessageFillKey)
                }
            }
        }
    }
}

#if DEBUG
struct RoomsListScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RoomsListScreen()
        }
    }
}
#endif
