///
//  Session.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import DittoSwift
import Foundation

//enum SessionType: CaseIterable {
//    case discussion
//    case qa
//    case talks
//    case hackathon
//    case social
//    case other
//    case undefined
//    
//    var title: String {
//        switch self {
//        case .discussion: return "Discussion"
//        case .qa:         return "Q&A"
//        case .talks:      return "Talks"
//        case .hackathon:  return "Hackathon"
//        case .social:     return "Social"
//        case .other:      return "Other"
//        case .undefined:  return "Undefined"
//        }
//    }
//}
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
    var attendeeIds: [String:Bool] //[userId]    
    let messagesId: String?
    let notesId: String?
    let createdBy: String
    let createdOn: Date
}

extension Session {
    init(document: DittoDocument) {
        self.id = document[dbIdKey].stringValue
        self.title = document[sessionTitleKey].stringValue
        self.type = document[sessionTypeKey].string ?? SessionType.undefined.rawValue
        self.description = document[descriptionKey].stringValue
        self.presenterIds = document[presenterIdsKey].dictionaryValue as? [String:Bool] ?? [:]
        self.attendeeIds = document[attendeeIdsKey].dictionaryValue as? [String:Bool] ?? [:]
        self.messagesId = document[messagesIdKey].stringValue
        self.notesId = document[notesIdKey].stringValue
        self.createdBy = document[createdByKey].stringValue
        self.createdOn = DateFormatter.isoDate.date(from: document[createdOnKey].stringValue) ?? Date()
    }
}

extension Session {
    func docDictionary() -> [String:Any?] {
        [
            dbIdKey: id,
            sessionTitleKey: title,
            sessionTypeKey: type,
            descriptionKey: description,
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
    static func prePopulate() {//} -> [Session] {
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
