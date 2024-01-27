///
//  SessionsManager.swift
//  DittoChat
//
//  Created by Eric Turner on 1/26/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import Combine
import DittoSwift
import SwiftUI 

class SessionsManager: ObservableObject {
    
    var PREPOPULATE = false
    
    static let shared = SessionsManager()
    
    @Published var sessions = [Session]()
    @Published var sessionTypes = [String]()
    @Published var dittoTeams = [String]()
    
    let dataManager = DataManager.shared    
    var ditto = DittoInstance.shared.ditto
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        allSessionsPublisher()
            .receive(on: DispatchQueue.main)
            .sink {[weak self] items in
                guard let self = self else { return }
                print("SessionsManager received \(items.count) sessions")
                sessions = items
            }
            .store(in: &cancellables)

        store[dittoOrgIdKey].findByID(dittoTeamsIdKey)
            .singleDocumentLiveQueryPublisher()
            .receive(on: DispatchQueue.main)
            .compactMap { doc, _ in return doc }
            .sink {[weak self] doc in
                guard let self = self else { return }
                let teamsDict = doc[teamsKey].dictionaryValue
                dittoTeams = Array(teamsDict.keys)
                print("teamsDict.count: \(dittoTeams.count)") 
            }
            .store(in: &cancellables)

        store[dittoOrgIdKey].findByID(sessionTypesIdKey)
            .singleDocumentLiveQueryPublisher()
            .receive(on: DispatchQueue.main)
            .compactMap { doc, _ in return doc }
            .sink {[weak self] doc in
                guard let self = self else { return }
                let typesDict = doc[typesKey].dictionaryValue
                sessionTypes = Array(typesDict.keys)
                print("typesDict.count: \(sessionTypes.count)") 
            }
            .store(in: &cancellables)

        prePopulate()
    }
    
    var store: DittoStore { ditto.store }
    var sessionsUsers: [SessionsUser] { dataManager.sessionsUsers }
    var sessionsCollection: DittoCollection { store[sessionsIdKey] }
    var currentUserId: String? { dataManager.currentUserId }
    
    func allSessionsPublisher() -> AnyPublisher<[Session], Never> {
        ditto.store[sessionsIdKey]
            .findAll()
//            .sort(createdOnKey, direction: .ascending)
            .liveQueryPublisher()
            .receive(on: DispatchQueue.main)
            .map { docs, _ in
                docs.map { Session(document: $0) }                
            }
            .eraseToAnyPublisher()        
    }
    
    func sessionPublisher(for session: Session) -> AnyPublisher<Session?, Never> {
        ditto.store[sessionsIdKey]
            .findByID(session.id)
            .singleDocumentLiveQueryPublisher()
            .compactMap { doc, _ in return doc }
            .map { Session(document: $0) }
            .eraseToAnyPublisher()
    }
    
    func allSessionsUsersPublisher() -> AnyPublisher<[SessionsUser], Never>  {
        ditto.store[usersKey].findAll().liveQueryPublisher()
            .map { docs, _ in
                docs.map { SessionsUser(document: $0) }
            }
            .eraseToAnyPublisher()
    }
}

extension SessionsManager {
    
    func prePopulate() {
        guard PREPOPULATE else { return }
        
        upsertSessions()
        upsertTypes()
        upsertTeams()
        
        PREPOPULATE = false
    }
    
    func upsertSessions() {
        let sessions = [
            Session(
                id: "BPAnywhere" , title: "Big Peer Anywhere Plan", 
                type: "Discussion", 
                description: "Flesh out more details on a plan for Big Peer Anywhere this year. Ideally this would include Federal.", 
                presenterIds: [:], attendeeIds: [:], 
                chatRoomId: "BPAnywhereChatRoom", messagesId: "BPAnywhereMessages", notesId: "BPAnywhereNotes", 
                createdBy: "", createdOn: Date()
            )
        ]
        
        for session in sessions {
            _ = try? store[sessionsIdKey]
                .upsert(session.docDictionary(), writeStrategy: .insertDefaultIfAbsent)
        }        
    }
    
    func upsertTypes() {
        let typesDoc: [String: Any] = [
            dbIdKey:sessionTypesIdKey, 
            typesKey: [
                "Discussion": true,
                "Q&A": true,
                "Talks": true,
                "Hackathon": true,
                "Social": true,
                "Other": true,
                undefinedTypeKey: true
            ]
        ]
        _ = try? store[dittoOrgIdKey].upsert(typesDoc, writeStrategy: .insertDefaultIfAbsent)
    }
    
    func upsertTeams() {
        // Teams
        let teamsDoc: [String: Any] = [
            dbIdKey: dittoTeamsIdKey, 
            teamsKey: [
                "Big Peer": true,
                "Cloud Services": true,
                "Customer Experience": true,
                "Executive": true,
                "Federal": true,
                "HR": true,
                "Legal": true,
                "Marketing": true,
                "Operations": true,
                "Product": true,
                "Small Peer": true,
                "Replication": true,
                "Sales": true,
                "Transport": true,
                "Undefined": true
            ]
        ]
        
        _ = try? store[dittoOrgIdKey].upsert(teamsDoc, writeStrategy: .insertDefaultIfAbsent)
    }
}

