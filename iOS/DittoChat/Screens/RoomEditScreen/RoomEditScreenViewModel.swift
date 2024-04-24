//
//  RoomEditScreenViewModel.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/20/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//

import Combine
import Foundation

class RoomEditScreenViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var saveButtonDisabled = false
    @Published var roomIsPrivate = false
    @Published var isValid = true

    init() {
        $name
            .map { $0.isEmpty }
            .assign(to: &$saveButtonDisabled)
    }

    func createRoom() {
        let _ = DataManager.shared.createRoom(name: name, isPrivate: roomIsPrivate)
    }
}
