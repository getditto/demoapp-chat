///
//  SessionsModel.swift
//  DittoChat
//
//  Created by Eric Turner on 1/26/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import Combine
import DittoSwift
import Observation
import SwiftUI

enum SelectedUsersType { 
    case presenters, attendees
    var title: String {
        switch self {
        case .presenters: return "Presenter(s)"
        case .attendees:  return "Attendees"
        }
    }
}

typealias SelectedUsers = [UserWrapper]

@Observable class SessionsModel {
////    var dataManager = DataManager.shared
//    var sessionsManager = SessionsManager.shared
//    private(set) var sessions: [Session] = []
//    var sessionsUsers = [SessionsUser]()
////    var observableSession = ObservableSession()
//
////    var sessionTypes = [String]()
////    var allPresenters = SelectedUsers()//[UserWrapper]()
////    var allAttendees  = SelectedUsers()//[UserWrapper]()
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        sessionsManager.allSessionsPublisher()
//            .receive(on: DispatchQueue.main)
//            .sink {[weak self] items in
//                guard let self = self else { return }
//                print("SessionsListVM received \(items.count) sessions")
//                sessions = items
//            }
//            .store(in: &cancellables)
//        
//#warning("DON'T UPDATE UserWrappers for every Users collection update!")
//        sessionsManager.allSessionsUsersPublisher()
//            .receive(on: DispatchQueue.main)
//            .sink {[weak self] users in
//                guard let self = self else { return }
////                allPresenters = users.sorted(by: { $0.firstName < $1.firstName } )
////                    .map { UserWrapper($0) }
////                allAttendees  = users.sorted(by: { $0.firstName < $1.firstName } )
////                    .map { UserWrapper($0) }
//            }
//            .store(in: &cancellables)
//    }
}

// Sessions Editing
extension SessionsModel {    
//    var presenterIds: [String:Bool] {
//        selectedUserIds(allPresenters)
//    }
//    var attendeeIds: [String:Bool] {
//        selectedUserIds(allAttendees)
//    }    
//    private func selectedUserIds(_ users: [UserWrapper]) -> [String:Bool] {
//        users
//            .filter { $0.isSelected }
//            .reduce(into: [:]) { dict, userWrapper in dict[userWrapper.id] = true }        
//    }
//
//    var presenterNames: String {
//        selectedUserNames(allPresenters)
//    }
//    var attendeeNames: String {
//        selectedUserNames(allAttendees)
//    }        
//    private func selectedUserNames(_ users: [UserWrapper]) -> String {
//        users
//            .sorted(by: { $0.firstName < $1.firstName } )
//            .filter { $0.isSelected }
//            .map { $0.fullName }            
//            .joined(separator: ", ")
//    }

//    func saveSession(_ sesh: Session, isNew: Bool, title: String, type: String, descr: String) {
////        guard canSave else { print("SessionEditView.\(#function): canSave == FALSE --> return"); return }
//        
//        if isNew {
//            let newSesh = newSessionHelper(sesh, title: title, type: type, descr: descr)            
//            let _ = try? dataManager.sessionsColl.upsert(newSesh.docDictionary())
//        } else {
//            let _ = dataManager.sessionsColl.findByID(sesh.id).update {[weak self] mutableDoc in
//                guard let self = self else { print("SessionModel.\(#function) - ERROR"); return }
//                mutableDoc?[sessionTitleKey].set(title)
//                mutableDoc?[typeKey].set(type)
//                mutableDoc?[sessionDescriptionKey].set(descr)
//                mutableDoc?[presenterIdsKey].set(presenterIds)
//                mutableDoc?[attendeeIdsKey].set(attendeeIds)
//                mutableDoc?[lastUpdatedByKey].set(dataManager.currentUserId!)
//                mutableDoc?[lastUpdatedOnKey].set(DateFormatter.isoDate.string(from: Date()))
//            }
//        }
//    }
//    
//    func newSessionHelper(_ sesh: Session, title: String, type: String, descr: String) -> Session {
//        Session(
//            id: sesh.id, title: title, type: type, description: descr, 
//            presenterIds: presenterIds, attendeeIds: attendeeIds, 
//            messagesId: msgsId, notesId: notesId, 
//            createdBy: sesh.createdBy, createdOn: sesh.createdOn
//        )
//    }
}


/// Make the @Observable SessionsData object available from the Environment
struct SessionsModelKey: EnvironmentKey {
    static var defaultValue = SessionsModel()
}
extension EnvironmentValues {
    var sessionsModel: SessionsModel {
        get { self[SessionsModelKey.self] }
        set { self[SessionsModel.self] = newValue }
    }
}
