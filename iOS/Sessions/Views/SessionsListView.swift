///
//  SessionsListView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import Combine
import SwiftUI

/*
class SessionsListVM: ObservableObject {
    @Published private(set) var sessions: [Session] = []
    @Published var presentCreateSession = false
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
*/
class SessionsListVM: ObservableObject {
    @Published var sessions = [Session]()
    @Published var presentCreateSession = false
    @Published var userIsValidated = false

    var cancelleables = Set<AnyCancellable>()
    init() {
        DataManager.shared.currentUserIdPublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] userId in
                guard let self = self else { return }
                userIsValidated = (userId != nil)
            }
            .store(in: &cancelleables)
        
        SessionsManager.shared.allSessionsPublisher()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] seshons in 
                guard let self = self else { return }
                sessions = seshons
            }
            .store(in: &cancelleables)
    }
}

struct SessionsListView: View {
    @StateObject var vm = SessionsListVM()    
//    @State var vm = SessionsListVM()
//    private var sessionsManager = SessionsManager.shared

    var body: some View {
        if !vm.userIsValidated {
            SessionsUserProfileView()
        } else {            
            List {
                Section("Sessions") {//}( vm.sessions.count > 0 ? publicRoomsTitleKey : "" ) {
                    ForEach(vm.sessions) { session in//, id: \.self) { session in
                        NavigationLink(value: session) {
                            SessionsListRowItem(session)
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
            .sheet(isPresented: $vm.presentCreateSession) {
                SessionEditView()
            }
        //        .sheet(isPresented: $viewModel.presentSettingsView) {
        //            SettingsScreen()
        //        }
            .toolbar {
//            ToolbarItemGroup(placement: .navigationBarLeading ) {x
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
                ToolbarItemGroup(placement: .navigationBarTrailing) {
//                Button {
//                    viewModel.scanButtonAction()
//                } label: {
//                    Label(scanPrivateRoomTitleKey, systemImage: qrCodeViewfinderKey)
//                }
                    Button {
                        vm.presentCreateSession = true
                    } label: {
                        Label("", systemImage: plusButtonImgKey)
                    }
                }
            }
        }
    }
}

#Preview {
    SessionsListView()
}
