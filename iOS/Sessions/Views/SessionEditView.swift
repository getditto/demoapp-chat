///
//  SessionEditView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import Combine
import Observation
import SwiftUI

//enum SessionsUsernameType { 
//    case presenters, attendees
//    var title: String {
//        switch self {
//        case .presenters: return "Presenter(s)"
//        case .attendees:  return "Attendees"
//        }
//    }
//}

@Observable class SessionEditVM {    
    var session = ObservableSession()
    var dummyTxt: String = "" // for disabled presenter/attendees textfields
    var presentPresentersSheet = false
    var presentAttendeesSheet = false    

    init(_ sesh: Session? = nil) {
        session = ObservableSession(sesh)
    }
    
    func save() {
        session.save()
    }
}

struct SessionEditView: View {
    @Environment(\.dismiss) private var dismiss
//    @Environment(\.sessionsModel) private var sessionsModel    
    @State var vm = SessionEditVM()
    @FocusState var titleHasFocus : Bool
    @FocusState var descriptionHasFocus : Bool
    @FocusState var chatIdHasFocus : Bool
    @FocusState var notesIdHasFocus : Bool
    private var sessionsManager = SessionsManager.shared

    init(_ sesh: Session? = nil) {
        vm = SessionEditVM(sesh)
    }

    var body: some View {

        NavigationView {
            Form {                
                Section {
                    TextField("Title", text: $vm.session.title)
                        .focused($titleHasFocus)
                    
                    typePickerView()
                }
                
                Section {                    
                    TextField("Description", text: $vm.session.description, axis: .vertical)
                        .lineLimit(nil)
                        .focused($descriptionHasFocus)
                }
                
                Section {
                    Button {
                        vm.presentPresentersSheet = true
                    } label: {                        
                        selectedUsernamesView(.presenters)
                    }
                }
                
                Section {
                    Button {
                        vm.presentAttendeesSheet = true
                    } label: {                        
                        selectedUsernamesView(.attendees)
                    }
                }
                
                Section {
                    TextField("Unique chat collection name", text: $vm.session.chatRoomId)
                        .focused($chatIdHasFocus)

                    TextField("Unique private notes collection name", text: $vm.session.notesId)
                        .focused($notesIdHasFocus)                    
                }
            }
            .sheet(isPresented: $vm.presentPresentersSheet) {
                SelectedUsersView(type: .presenters, session: vm.session)
                    .environment(vm)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(cancelTitleKey)
                    }
                    .buttonStyle(.borderless)
                }
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(vm.session.title)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
//                        vm.saveEdit()
                        vm.save()
                    } label: {
                        Text(saveTitleKey)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
    
    func typePickerView() -> some View {
        VStack {
            Picker(selection: $vm.session.type, label: Text("Session type")) {
                ForEach(SessionType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type.rawValue)
                }
            }
        }
    }
    
    func selectedUsernamesView(_ type: SelectedUsersType) -> some View {
        let usernames = type == .attendees ? vm.session.attendeeNames : vm.session.presenterNames
        return HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(type.title)
                
                TextField("\(usernames.isEmpty ? "(None selected)" : usernames)",
                          text: $vm.dummyTxt, 
                          axis: .vertical
                )
                .lineLimit(nil)
                .disabled(true)
            }
            .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.body)
                .opacity(0.5)
        }
    }
}


//#Preview {
//    SessionEditView()
//}
