//
//  RoomsListScreenVM.swift
//  DittoChat
//
//  Created by Eric Turner on 2/17/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Combine
import Foundation

class RoomsListScreenVM: ObservableObject {
    @Published var presentProfileScreen: Bool = false
    @Published var presentCreateRoomScreen = false
    @Published var presentScannerView = false
    @Published var presentSettingsView = false
    @Published var publicRooms: [Room] = []
    @Published var privateRooms: [Room] = []
    @Published var defaultPublicRoom: Room?
    
    init() {
        self.presentProfileScreen = DataManager.shared.currentUserId == nil
        
        DataManager.shared
            .publicRoomsPublisher
            .receive(on: DispatchQueue.main)
            .map {[weak self] rooms in
                self?.defaultPublicRoom = rooms.first(where: { $0.id == publicKey })
                // remove default public room; it's presented by itself in 1st list section
                return rooms.filter { $0.id != publicKey }
            }
            .assign(to: &$publicRooms)
        
        DataManager.shared
            .privateRoomsPublisher
            .map { privRooms in
                privRooms.sorted(by: {$0.createdOn > $1.createdOn } )
            }
            .assign(to: &$privateRooms)
    }

    func profileButtonAction() {
        presentProfileScreen = true
    }

    func createRoomButtonAction() {
        presentCreateRoomScreen = true
    }
    
    func scanButtonAction() {
        presentScannerView = true
    }
    
    func joinPrivateRoom(code: String) {
        DataManager.shared.joinPrivateRoom(qrCode: code)
    }

    func archiveRoom(_ room: Room) {
        DataManager.shared.archiveRoom(room)
    }
}
