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
    @Published var dismissDisabled = false
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
            .flatMap { [weak self] rooms in
                self?.gatherRoomsPublisher(rooms, isPrivate: false) ?? Empty().eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$archivedPublicRooms)

        DataManager.shared.archivedPrivateRoomsPublisher()
            .flatMap { [weak self] rooms in
                self?.gatherRoomsPublisher(rooms, isPrivate: true) ?? Empty().eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$archivedPrivateRooms)

        DataManager.shared.allUsersPublisher()
            .assign(to: &$users)
    }

    func gatherRoomsPublisher(_ rooms: [Room], isPrivate: Bool) -> AnyPublisher<[Room], Never> {
        Future { [weak self] promise in
            guard let self = self else { return }
            Task {
                let rooms = await self.processRooms(rooms: rooms, isPrivate: isPrivate)
                promise(.success(rooms))
            }
        }
        .eraseToAnyPublisher()
    }

    func processRooms(rooms: [Room], isPrivate: Bool) async -> [Room] {
        var (replicated, unreplicated) = ([Room](), [Room]())

        for room in rooms {
            let result = await DataManager.shared.room(for: room)
            if let r = result {
                replicated.append(r)
            } else {
                unreplicated.append(room)
            }
        }

        unreplicated.sort { $0.createdOn > $1.createdOn }
        replicated.sort { $0.createdOn > $1.createdOn }

        let unrep = unreplicated
        await MainActor.run { [weak self] in
            if isPrivate {
                self?.unReplicatedPrivateRooms = unrep
            } else {
                self?.unReplicatedPublicRooms = unrep
            }
        }

        return replicated
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
