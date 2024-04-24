//
//  ProfileScreenViewModel.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/20/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//

import Combine
import Foundation

class ProfileScreenViewModel: ObservableObject {
    @Published var dismissDisabled = false
    @Published var saveButtonDisabled = false
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var isValid = true
    @Published var user: ChatUser?

    init() {
        DataManager.shared
            .currentUserPublisher()
            .map { $0?.firstName ?? "" }
            .assign(to: &$firstName)

        DataManager.shared
            .currentUserPublisher()
            .map { $0?.lastName ?? "" }
            .assign(to: &$lastName)

        DataManager.shared.currentUserIdPublisher
            .map { $0 == nil }
            .assign(to: &$dismissDisabled)

        $firstName.combineLatest($lastName)
            .map { firstName, lastName -> Bool in
                return firstName.isEmpty || lastName.isEmpty
            }
            .assign(to: &$saveButtonDisabled)
    }

    func saveChanges() {
        DataManager.shared.saveCurrentUser(
            firstName: firstName.trim(),
            lastName: lastName.trim()
        )
    }
}
