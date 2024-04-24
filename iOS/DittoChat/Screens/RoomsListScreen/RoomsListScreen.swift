//
//  RoomsListScreen.swift
//  DittoChat
//
//  Created by Eric Turner on 2/17/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import SwiftUI

public struct RoomsListScreen: View {
    @ObservedObject var viewModel = RoomsListScreenVM()

    public init() { /*Make init public access level*/ }

    public var body: some View {
        List {
            if let defaultPublicRoom = viewModel.defaultPublicRoom {
                Section(openPublicRoomTitleKey) {
                    NavigationLink(destination: ChatScreen(room: defaultPublicRoom)) {
                        RoomsListRowItem(room: defaultPublicRoom)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(action: {
                            viewModel.toggleSubscriptionFor(room: defaultPublicRoom)
                        }, label: {
                            Text("Sub")
                        })
                    }
                }
            }
            Section( viewModel.publicRooms.count > 0 ? publicRoomsTitleKey : "" ) {
                ForEach(viewModel.publicRooms) { room in
                    NavigationLink(destination: ChatScreen(room: room)) {
                        RoomsListRowItem(room: room)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(settingsHideTitleKey) {
                            viewModel.archiveRoom(room)
                        }
                        .tint(.red)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(action: {
                            viewModel.toggleSubscriptionFor(room: room)
                        }, label: {
                            Text("Sub")
                        })
                    }
                }
            }
            
            Section( viewModel.privateRooms.count > 0 ? privateRoomsTitleKey : "" ) {
                ForEach(viewModel.privateRooms) { room in
                    NavigationLink(destination: ChatScreen(room: room)) {
                        RoomsListRowItem(room: room)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(settingsLeaveTitleKey) {
                            viewModel.archiveRoom(room)
                        }
                        .tint(.red)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(action: {
                            viewModel.toggleSubscriptionFor(room: room)
                        }, label: {
                            Text("Sub")
                        })
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
            ToolbarItemGroup(placement: .navigationBarLeading) {
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
            ToolbarItemGroup(placement: .principal) {
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
        NavigationView {
            RoomsListScreen()
        }
    }
}
#endif
