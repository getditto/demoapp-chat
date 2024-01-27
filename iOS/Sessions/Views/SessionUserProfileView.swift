///
//  SessionsUserProfileView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/26/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import SwiftUI

import Combine
import Foundation

class SessionsUserProfileVM: ObservableObject {
//    @Published var dismissDisabled = false
    @Published var saveButtonDisabled = false
//    @Published var firstName: String = ""
//    @Published var lastName: String = ""
//    @Published var team: String = ""
    @Published var user = SessionsUser.unknownUser()
    
    init() {
//        DataManager.shared
//            .currentUserPublisher()
//            .map { $0?.firstName ?? "" }
//            .assign(to: &$firstName)
//        
//        DataManager.shared
//            .currentUserPublisher()
//            .map { $0?.lastName ?? "" }
//            .assign(to: &$lastName)
//
//        DataManager.shared.currentUserIdPublisher
//            .map { $0 == nil }
//            .assign(to: &$saveButtonDisabled)
//
//        $firstName.combineLatest($lastName)
//            .map { firstName, lastName -> Bool in
//                return firstName.isEmpty || lastName.isEmpty
//            }
//            .assign(to: &$saveButtonDisabled)
    }

    func saveChanges() {
        
        DataManager.shared.saveCurrentUser(
            firstName: firstName.trim(),
            lastName: lastName.trim()
        )
    }
}


struct SessionsUserProfileView: View {
//    @Environment(\.dismiss) private var dismiss
    @StateObject var vm = SessionsUserProfileVM()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(firstNameTitleKey, text: $vm.firstName)
                    TextField(lastNameTitleKey, text: $vm.lastName)
                }
            }
            .navigationTitle(dittoTeamProfileTitleKey)
            .toolbar(content: {
//                ToolbarItemGroup(placement: .navigationBarLeading) {
//                    if !vm.dismissDisabled {
//                        Button {
//                            dismiss()
//                        } label: {
//                            Text(cancelTitleKey)
//                        }
//                    }
//                }
                Button {
//                    vm.saveChanges()
//                    dismiss()
                } label: {
                    Text(saveChangesTitleKey)
                }
                .disabled(vm.saveButtonDisabled)
            })
//            .interactiveDismissDisabled(vm.dismissDisabled)
        }
    }
}

#Preview {
    SessionsUserProfileView()
}
