//
//  ProfileScreen.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/20/22.
//

import SwiftUI

struct ProfileScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = ProfileScreenViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(firstNameTitleKey, text: $viewModel.firstName)
                    TextField(lastNameTitleKey, text: $viewModel.lastName)
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
