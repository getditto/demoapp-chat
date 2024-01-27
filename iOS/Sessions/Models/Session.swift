///
//  Session.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import DittoSwift
import Foundation
import Observation


//tmp for sessions edit picker for now
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
    var chatRoomId: String    
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
        type = document[typeKey].string ?? undefinedTypeKey
        description = document[sessionDescriptionKey].stringValue
        presenterIds = document[presenterIdsKey].dictionaryValue as? [String:Bool] ?? [:]
        attendeeIds = document[attendeeIdsKey].dictionaryValue as? [String:Bool] ?? [:]
        chatRoomId = document[chatRoomIdKey].stringValue
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
            typeKey: type,
            sessionDescriptionKey: description,
            presenterIdsKey: presenterIds,
            attendeeIdsKey: attendeeIds,
            messagesIdKey: messagesId,
            chatRoomIdKey: chatRoomId,
            notesIdKey: notesId,
            createdByKey: createdBy,
            createdOnKey: DateFormatter.isoDate.string(from: createdOn)
        ]
    }
}

extension Session {
    static func new() -> Session {
        Session(
            id: UUID().uuidString, title: "", type: undefinedTypeKey, 
            description: "", 
            presenterIds: [:], attendeeIds: [:], 
            chatRoomId: "", messagesId: "", notesId: "", 
            createdBy: DataManager.shared.currentUserId ?? unknownUserIdKey, 
            createdOn: Date()
        )
    }
}
