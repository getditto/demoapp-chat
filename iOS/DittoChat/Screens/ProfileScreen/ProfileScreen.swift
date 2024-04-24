//
//  ProfileScreen.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/20/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//

import SwiftUI

struct ProfileScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = ProfileScreenViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(firstNameTitleKey, text: Binding(
                        get: { viewModel.firstName },
                        set: { newValue in
                            if newValue.isValidInput(newValue) {
                                viewModel.firstName = String(newValue.prefix(2500))
                                viewModel.isValid = true
                            } else {
                                viewModel.isValid = false
                            }
                        }
                    ))
                    TextField(lastNameTitleKey, text: Binding(
                        get: { viewModel.lastName },
                        set: { newValue in
                            if newValue.isValidInput(newValue) {
                                viewModel.lastName = String(newValue.prefix(2500))
                                viewModel.isValid = true
                            } else {
                                viewModel.isValid = false
                            }
                        }
                    ))
                }
                Button {
                    viewModel.saveChanges()
                    dismiss()
                } label: {
                    Text(saveChangesTitleKey)
                }
                .disabled(viewModel.saveButtonDisabled)
            }
            .navigationTitle(profileTitleKey)
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if !viewModel.dismissDisabled {
                        Button {
                            dismiss()
                        } label: {
                            Text(cancelTitleKey)
                        }
                    }
                }
            })
            .interactiveDismissDisabled(viewModel.dismissDisabled)
        }
    }
}

#if DEBUG
struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
    }
}
#endif
