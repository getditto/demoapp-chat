///
//  DataManagerSessions.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import Combine
import DittoSwift
import SwiftUI

extension DataManager {
    var ditto: Ditto { 
        DittoInstance.shared.ditto
    }
    
    var store: DittoStore {
        ditto.store
    }
    
    var sessionsColl: DittoCollection {
        store[sessionsKey]
    }
        
    func allSessionsPublisher() -> AnyPublisher<[Session], Never> {
        ditto.store[sessionsKey]
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
        ditto.store[sessionsKey]
            .findByID(session.id)
            .singleDocumentLiveQueryPublisher()
            .compactMap { doc, _ in return doc }
            .map { Session(document: $0) }
            .eraseToAnyPublisher()
    }
    
    func allSessionUsersPublisher() -> AnyPublisher<[SessionUser], Never>  {
        return ditto.store[usersKey].findAll().liveQueryPublisher()
            .map { docs, _ in
                docs.map { SessionUser(document: $0) }
            }
            .eraseToAnyPublisher()
    }
}
