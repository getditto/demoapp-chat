//
//  RoomEditScreen.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/20/22.
//

import SwiftUI

struct RoomEditScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel = RoomEditScreenViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Room Name", text: $viewModel.name)
                }
                Section {
                    HStack {
                        CheckboxButton(isChecked: $viewModel.roomIsPrivate)
                        Text("Private Room")
                        Spacer()
                    }
                }
                Section {
                    HStack {
                        Spacer()
                        
                        Button {
                            viewModel.createRoom()
                            dismiss()
                        } label: {
                            Text("Create Room")
                        }
                        .disabled(viewModel.saveButtonDisabled)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Create Room")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }

                }
            }
        }
    }
}

#if DEBUG
struct RoomEditScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoomEditScreen()            
        }
    }
}
#endif
