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

enum SessionUsernameType { 
//    case presenters(usernames: String)
//    case attendees (usernames: String)
    case presenters, attendees
    var title: String {
        switch self {
        case .presenters: return "Presenter(s)"
        case .attendees:  return "Attendees"
        }
    }
}

@Observable class SessionEditVM {
    var session = Session.new()
    var txtTitle: String = ""    
    var txtType: String = SessionType.undefined.rawValue
    var txtDescription: String = ""    
    var dummyTxt: String = "" // for disabled presenter/attendees textfields
    var msgsId: String = ""
    var notesId: String = ""
    var allPresenters = [UserWrapper]()
    var allAttendees = [UserWrapper]()

    var presentPresentersSheet = false
    var presentAttendeesSheet = false    

    private var isNewSession = true
    private var cancellable = AnyCancellable({})

    init(_ sesh: Session? = nil) {
        if let seshon = sesh { 
            session = seshon
            isNewSession = false
        }
        txtTitle = session.title        
        txtType = session.type
        txtDescription = session.description
        
        cancellable = DataManager.shared.allSessionUsersPublisher()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] users in
                guard let self = self else { return }
                allPresenters = users.sorted(by: { $0.firstName < $1.firstName } )
                    .map { UserWrapper($0) }
                allAttendees  = users.sorted(by: { $0.firstName < $1.firstName } )
                    .map { UserWrapper($0) }
            }
    }
    
    private var presenterIds: [String:Bool] {
        selectedUserIds(allPresenters)
    }
    private var attendeeIds: [String:Bool] {
        selectedUserIds(allAttendees)
    }    
    private func selectedUserIds(_ users: [UserWrapper]) -> [String:Bool] {
        users
            .filter { $0.isSelected }
            .reduce(into: [:]) { dict, userWrapper in dict[userWrapper.id] = true }        
    }

    var presenterNames: String {
        selectedUserNames(allPresenters)
    }
    var attendeeNames: String {
        selectedUserNames(allAttendees)
    }    
    private func selectedUserNames(_ users: [UserWrapper]) -> String {
        users
            .sorted(by: { $0.firstName < $1.firstName } )
            .filter { $0.isSelected }
            .map { $0.fullName }            
            .joined(separator: ", ")
    }

    func saveEdit() {
        guard canSave else { print("SessionEditView.\(#function): canSave == FALSE --> return"); return }
        
        if isNewSession {
            let newSesh = newSessionHelper(session)            
            let _ = try? DataManager.shared.sessionsColl.upsert(newSesh.docDictionary())
        } else {
            let _ = DataManager.shared.sessionsColl.findByID(session.id).update {[weak self] mutableDoc in
                guard let self = self else { print("SessionEdit.\(#function) - ERROR"); return }
                mutableDoc?[sessionTitleKey].set(txtTitle)
                mutableDoc?[sessionTypeKey].set(txtType)
                mutableDoc?[sessionDescriptionKey].set(txtDescription)
                mutableDoc?[presenterIdsKey].set(presenterIds)
                mutableDoc?[attendeeIdsKey].set(attendeeIds)
                mutableDoc?[lastUpdatedByKey].set(DataManager.shared.currentUserId!)
                mutableDoc?[lastUpdatedOnKey].set(DateFormatter.isoDate.string(from: Date()))
            }
        }
    }
    
    func newSessionHelper(_ sesh: Session) -> Session {
        Session(
            id: sesh.id, title: txtTitle, type: txtType, description: txtDescription, 
            presenterIds: presenterIds, attendeeIds: attendeeIds, messagesId: msgsId, 
            notesId: notesId, createdBy: sesh.createdBy, createdOn: sesh.createdOn
        )
    }
    
    var canSave: Bool {
        !txtTitle.isEmpty &&
        !txtDescription.isEmpty &&
        !msgsId.isEmpty && // need to check for uniqueness across collection names
        !notesId.isEmpty &&
        !presenterIds.isEmpty
    }
    
    var chatIdIsValid: Bool {
        true
    }
}

struct SessionEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State var vm = SessionEditVM()
    @FocusState var titleHasFocus : Bool
    @FocusState var descriptionHasFocus : Bool
    @FocusState var chatIdHasFocus : Bool
    @FocusState var notesIdHasFocus : Bool

    init(_ sesh: Session? = nil) {
        vm = SessionEditVM(sesh)
    }

    var body: some View {

        NavigationView {
            Form {                
                Section {
                    TextField("Title", text: $vm.txtTitle)
                        .focused($titleHasFocus)
                    
                    typePickerView()
                }
                
                Section {                    
                    TextField("Description", text: $vm.txtDescription, axis: .vertical)
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
                    TextField("Unique chat collection name", text: $vm.msgsId)
                        .focused($chatIdHasFocus)

                    TextField("Unique private notes collection name", text: $vm.notesId)
                        .focused($notesIdHasFocus)                    
                }
            }
            .sheet(isPresented: $vm.presentPresentersSheet) {
                PresentersView()
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
                        Text(vm.txtTitle)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        vm.saveEdit()
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
                    Text(type.rawValue).tag(type.rawValue)//.font(Font.title)
                }
            }
        }
    }
    
    func selectedUsernamesView(_ type: SessionUsernameType) -> some View {
        var usernames = type == .attendees ? vm.attendeeNames : vm.presenterNames
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
