///
//  SessionsListView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import Combine
import SwiftUI

class SessionsListVM: ObservableObject {
    @Published private(set) var sessions: [Session] = []
    private var cancellable = AnyCancellable({})

    init() {
//        Session.prePopulate()
        cancellable = DataManager.shared.allSessionsPublisher()
            .sink {[weak self] items in
                print("SessionsListVM received \(items.count) sessions")
                self?.sessions = items
            }
//            .assign(to: &$sessions)
    }
} 

struct SessionsListView: View {
    @StateObject var vm = SessionsListVM()    

    var body: some View {
        List {
            Section("Sessions") {//}( vm.sessions.count > 0 ? publicRoomsTitleKey : "" ) {
                ForEach(vm.sessions, id: \.self) { session in
                    NavigationLink(value: session) {
                        SessionsListRowItem(session: session)
                    }
//                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                        Button(settingsHideTitleKey) {
//                            viewModel.archiveRoom(room)
//                        }
//                        .tint(.red)
//                    }
                }
            }
            
//            Section( viewModel.privateRooms.count > 0 ? privateRoomsTitleKey : "" ) {
//                ForEach(viewModel.privateRooms) { room in
//                    NavigationLink(value: room) {
//                        RoomsListRowItem(room: room)
//                    }
//                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                        Button(settingsLeaveTitleKey) {
//                            viewModel.archiveRoom(room)
//                        }
//                        .tint(.red)
//                    }
//                }
//            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Session.self) { session in
            SessionView(session: session)
                .withErrorHandling()
        }
//        .sheet(isPresented: $viewModel.presentProfileScreen) {
//            ProfileScreen()
//        }
//        .sheet(isPresented: $viewModel.presentScannerView) {
//            ScannerView(
//                successAction: { code in
//                    viewModel.joinPrivateRoom(code: code)
//                }
//            )
//        }
//        .sheet(isPresented: $viewModel.presentCreateRoomScreen) {
//            RoomEditScreen()
//        }
//        .sheet(isPresented: $viewModel.presentSettingsView) {
//            SettingsScreen()
//        }
//        .toolbar {
//            ToolbarItemGroup(placement: .navigationBarLeading ) {
//                Button {
//                    viewModel.profileButtonAction()
//                } label: {
//                    Image(systemName: personCircleKey)
//                }
//                Button {
//                    viewModel.presentSettingsView = true
//                } label: {
//                    Image(systemName: gearShapeKey)
//                }
//            }
//            ToolbarItemGroup(placement: .principal ) {
//                Text(appTitleKey)
//                    .fontWeight(.bold)
//            }
//            ToolbarItemGroup(placement: .navigationBarTrailing) {
//                Button {
//                    viewModel.scanButtonAction()
//                } label: {
//                    Label(scanPrivateRoomTitleKey, systemImage: qrCodeViewfinderKey)
//                }
//                Button {
//                    viewModel.createRoomButtonAction()
//                } label: {
//                    Label(newRoomTitleKey, systemImage: plusMessageFillKey)
//                }
//            }
//        }
    }
}

#Preview {
    SessionsListView()
}