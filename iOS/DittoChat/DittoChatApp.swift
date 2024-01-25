//
//  DittoChatApp.swift
//  DittoChat
//
//  Created by Eric Turner on 12/6/22.
//

import Combine
import SwiftUI

class DittoChatAppVM: ObservableObject {
    @Published var basicChatAsRootView = DataManager.shared.basicChat
    
    init() {
        DataManager.shared.basicChatPublisher
            .assign(to: &$basicChatAsRootView)
    }
}

@main
struct DittoChatApp: App {
    @StateObject var vm = DittoChatAppVM()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
//                if vm.basicChatAsRootView {
//                    ChatScreen(room: Room.basicChatDummy)
//                        .withErrorHandling()
//                } else {
//                    RoomsListScreen()
                    SessionsListView()
//                }
            }
        }
    }
}
