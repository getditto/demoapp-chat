//
//  DittoChatApp.swift
//  DittoChat
//
//  Created by Eric Turner on 12/6/22.
//

import SwiftUI

@main
struct DittoChatApp: App {
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RoomsListScreen()
            }
        }
    }
}
