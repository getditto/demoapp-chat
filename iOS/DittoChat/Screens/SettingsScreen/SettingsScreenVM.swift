///
//  SettingsScreenVM.swift
//  DittoChat
//
//  Created by Eric Turner on 1/21/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Combine
import SwiftUI

class SettingsScreenVM: ObservableObject {
    @Published var archivedPublicRooms: [Room] = []
    @Published var unReplicatedPublicRooms: [Room] = []
    @Published var archivedPrivateRooms: [Room] = []
    @Published var unReplicatedPrivateRooms: [Room] = []
    @Published var showExportLogsSheet = false
    @Published var presentExportDataShare: Bool = false
    @Published var presentExportDataAlert: Bool = false
    @Published var users: [User] = []
    @Published var acceptLargeImages = DataManager.shared.acceptLargeImages
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
        DataManager.shared.archivedPublicRoomsPublisher()
            .map { pubRooms in
                var rooms = [Room]()
                var unRepRooms = [Room]()

                pubRooms.forEach { room in
                    DataManager.shared.room(for: room) { (result) in
                        if let r = result {
                            rooms.append(r)
                        } else {
                            unRepRooms.append(room)
                        }
                    }
                }
                unRepRooms.sort { $0.createdOn > $1.createdOn }
                self.unReplicatedPublicRooms = unRepRooms
                
                rooms.sort { $0.createdOn > $1.createdOn }
                return rooms
            }
            .assign(to: &$archivedPublicRooms)

        DataManager.shared.archivedPrivateRoomsPublisher()
            .handleEvents(receiveOutput: {[weak self] _ in
                self?.archivedPrivateRooms = []
                self?.unReplicatedPrivateRooms = []
            })
            .map { rooms in
                var privRooms = [Room]()
                var unRepRooms = [Room]()
                
                rooms.forEach { privRoom in
                    DataManager.shared.room(for: privRoom) { (result) in
                        if let r = result {
                            privRooms.append(r)
                        } else {
                            unRepRooms.append(privRoom)
                        }
                    }
 
                }
                unRepRooms.sort { $0.createdOn > $1.createdOn }
                self.unReplicatedPrivateRooms = unRepRooms
                
                privRooms.sort { $0.createdOn > $1.createdOn }
                return privRooms
            }
            .assign(to: &$archivedPrivateRooms)

        DataManager.shared.allUsersPublisher()
            .assign(to: &$users)
    }
    
    func roomForId(_ roomId: String) -> Room? {
        archivedPublicRooms.first(where: { $0.id == roomId} )
    }

    func unarchiveRoom(_ room: Room) {
        DataManager.shared.unarchiveRoom(room)
    }

    func deleteRoom(_ room: Room) {
        DataManager.shared.deleteRoom(room)
    }
    
    var versionFooter: String {
        let vSDK = DataManager.shared.sdkVersion
        let appInfo = DataManager.shared.appInfo
        return "\(appInfo)\nDitto SDK \(vSDK)"
    }

    // Set basicChat to inverse of useAdvanced arg
    func enableAdvancedFeatures(useAdvanced: Bool) {
        DataManager.shared.basicChat = !useAdvanced
    }

    func setLargeImagesPrefs(_ accept: Bool) {
        DataManager.shared.acceptLargeImages = accept
    }
}
