///
//  Session.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import DittoSwift
import Foundation

enum SessionType: String, Codable, CaseIterable {
    case discussion = "Discussion"
    case qa         = "Q&A"
    case talks      = "Talks"
    case hackathon  = "Hackathon"
    case social     = "Social"
    case other      = "Other"
    case undefined  = "Undefined"
}

struct Session: Identifiable, Hashable {
    var id: String
    var title: String
    var type: String
    var description: String
    var presenterIds: [String:Bool] //[userId]
    var attendeeIds: [String:Bool]  //[userId]    
    let messagesId: String
    let notesId: String
    let createdBy: String
    let createdOn: Date
    var lastUpdatedBy: String?
    var lastUpdatedOn: Date?
}

extension Session {
    init(document: DittoDocument) {
        id = document[dbIdKey].stringValue
        title = document[sessionTitleKey].stringValue
        type = document[sessionTypeKey].string ?? SessionType.undefined.rawValue
        description = document[sessionDescriptionKey].stringValue
        presenterIds = document[presenterIdsKey].dictionaryValue as? [String:Bool] ?? [:]
        attendeeIds = document[attendeeIdsKey].dictionaryValue as? [String:Bool] ?? [:]
        messagesId = document[messagesIdKey].stringValue
        notesId = document[notesIdKey].stringValue
        createdBy = document[createdByKey].stringValue
        createdOn = DateFormatter.isoDate.date(from: document[createdOnKey].stringValue) ?? Date()
        lastUpdatedBy = document[lastUpdatedByKey].string
        if let updatedOn = document[lastUpdatedOnKey].string {
            lastUpdatedOn = DateFormatter.isoDate.date(from: updatedOn) ?? Date()    
        }        
    }
}

extension Session {
    func docDictionary() -> [String:Any?] {
        [
            dbIdKey: id,
            sessionTitleKey: title,
            sessionTypeKey: type,
            sessionDescriptionKey: description,
            presenterIdsKey: presenterIds,
            attendeeIdsKey: attendeeIds,
            messagesIdKey: messagesId,
            notesIdKey: notesId,
            createdByKey: createdBy,
            createdOnKey: DateFormatter.isoDate.string(from: createdOn)
        ]
    }
}

extension Session {
    static func new() -> Session {
        Session(
            id: UUID().uuidString, title: "", type: SessionType.undefined.rawValue, 
            description: "", 
            presenterIds: [:], attendeeIds: [:], 
            messagesId: "", notesId: "", 
            createdBy: DataManager.shared.currentUserId ?? unknownUserIdKey, 
            createdOn: Date()
        )
    }
}


extension Session {
    static func prePopulate() {
        let sessions = [
            Session(
                id: UUID().uuidString, title: "Big Peer Anywhere Plan", type: SessionType.discussion.rawValue, 
                description: "Flesh out more details on a plan for Big Peer Anywhere this year. Ideally this would include Federal.", 
                presenterIds: [:], attendeeIds: [:], messagesId: "BPAnywhere", 
                notesId: "BPAnywhereNotes", 
                createdBy: "", 
                createdOn: Date()
            )
        ]
        
        for session in sessions {
            upsertSession(session)
        }
    }
    
    static func upsertSession(_ session: Session) {
        _ = try? DittoInstance.shared.ditto.store[sessionsKey]
            .upsert(session.docDictionary(), writeStrategy: .insertDefaultIfAbsent)
    }
}
