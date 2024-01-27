///
//  ObservableSession.swift
//  DittoChat
//
//  Created by Eric Turner on 1/26/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import DittoSwift
import Foundation
import Observation

/*
struct Session: Identifiable, Hashable {
    var id: String
    var title: String
    var type: String
    var description: String
    var presenterIds: [String:Bool] //[userId]
    var attendeeIds: [String:Bool]  //[userId]    
    var chatRoomId: String
    let messagesId: String
    let notesId: String
    let createdBy: String
    let createdOn: Date
    var lastUpdatedBy: String?
    var lastUpdatedOn: Date?
}
*/
@Observable class ObservableSession {
    var id = ""
    var title = ""
    var type = ""
    var description = ""
    var chatRoomId = ""
    var msgsId = ""
    var notesId = ""
    var createdBy: String? = SessionsManager.shared.currentUserId
    var createdOn = Date()
    var lastUpdatedBy: String? = SessionsManager.shared.currentUserId
    var lastUpdatedOn = Date()
    var allPresenters: SelectedUsers = [UserWrapper]()
    var allAttendees:  SelectedUsers = [UserWrapper]()
    
    var sessionTypes: [String] = SessionsManager.shared.sessionTypes
    var isNew = true
//    var dataManager = DataManager.shared
    var sessionsManager = SessionsManager.shared
    
    init() {}
//    init(_ sesh: Session? = nil, users: [SessionsUser]) {
    init(_ sesh: Session? = nil) {
        var seshon = Session.new()
        if let sesh = sesh { 
            seshon = sesh
            isNew = false
        }
        id = seshon.id
        title = seshon.title
        type = seshon.type
        description = seshon.description
        chatRoomId = seshon.chatRoomId
        msgsId = seshon.messagesId
        notesId = seshon.notesId
        createdBy = seshon.createdBy
        createdOn = seshon.createdOn
        if let lastBy = seshon.lastUpdatedBy { lastUpdatedBy = lastBy } 
        if let lastOn = seshon.lastUpdatedOn { lastUpdatedOn = lastOn }
        
        let users = sessionsManager.sessionsUsers
        allPresenters = users.sorted(by: { $0.firstName < $1.firstName } )
            .map { UserWrapper($0) }
        allAttendees  = users.sorted(by: { $0.firstName < $1.firstName } )
            .map { UserWrapper($0) }
    }
    
    var isValid: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !msgsId.isEmpty && // need to check for uniqueness across collection names
        !notesId.isEmpty &&
        !presenterIds.isEmpty
    }
    private func idIsUnique(_ collId: String) -> Bool {
        true
    }
    
    var presenterIds: [String:Bool] {
        selectedUserIds(allPresenters)
    }
    var attendeeIds: [String:Bool] {
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
}

extension ObservableSession {
    func save() {
//        guard canSave else { print("SessionEditView.\(#function): canSave == FALSE --> return"); return }
        
        if isNew {
            let newSession = newSessionHelper()            
            let _ = try? sessionsManager.sessionsCollection.upsert(newSession.docDictionary())
        } else {
            let _ = sessionsManager.sessionsCollection.findByID(id).update {[weak self] mutableDoc in
                guard let self = self else { print("SessionModel.\(#function) - ERROR"); return }
                mutableDoc?[sessionTitleKey].set(title)
                mutableDoc?[typeKey].set(type)
                mutableDoc?[sessionDescriptionKey].set(description)
                mutableDoc?[presenterIdsKey].set(presenterIds)
                mutableDoc?[attendeeIdsKey].set(attendeeIds)
                mutableDoc?[lastUpdatedByKey].set(sessionsManager.currentUserId)
                mutableDoc?[lastUpdatedOnKey].set(DateFormatter.isoDate.string(from: Date()))
            }
        }
    }
    
//    func newSessionHelper(_ sesh: Session, title: String, type: String, descr: String) -> Session {
    func newSessionHelper() -> Session {
        Session(
            id: id, title: title, type: type, description: description, 
            presenterIds: presenterIds, attendeeIds: attendeeIds, 
            chatRoomId: chatRoomId, messagesId: msgsId, notesId: notesId, 
            createdBy: createdBy ?? sessionsManager.currentUserId!, 
            createdOn: createdOn,
            lastUpdatedBy: lastUpdatedBy ?? sessionsManager.currentUserId!, 
            lastUpdatedOn: lastUpdatedOn
        )
    }

}
