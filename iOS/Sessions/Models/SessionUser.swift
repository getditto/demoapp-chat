///
//  SessionUser.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import DittoSwift
import Foundation

@Observable class UserWrapper: Identifiable {
    var user: SessionUser
    var isSelected = false
    init(_ usr: SessionUser) { user = usr }
    var id: String { user.id }    
    var firstName: String { user.firstName }
    var lastName: String { user.lastName }
    var fullName: String { user.fullName }
    var team: String { user.team }
}

enum DittoTeam: String, Codable, CaseIterable {
    case bigPeer       = "Big Peer"
    case cloudServices = "Cloud Services"
    case cx            = "Customer Experience"
    case executive     = "Executive"
    case federal       = "Federal"
    case hr            = "HR"
    case legal         = "Legal"
    case marketing     = "Marketing"
    case operations    = "Operations"
    case product       = "Product"
    case smallPeer     = "Small Peer"
    case replication   = "Replication"
    case sales         = "Sales"
    case transport     = "Transport"
    case undefined     = "Undefined"
}

struct SessionUser: Identifiable, Hashable, Equatable {
    var id: String
    var firstName: String
    var lastName: String
    var fullName: String {
        firstName + " " + lastName
    }
    var team: String
    
}

extension SessionUser {
    init(document: DittoDocument) {
        self.id = document[dbIdKey].stringValue
        self.firstName = document[firstNameKey].stringValue
        self.lastName = document[lastNameKey].stringValue
        self.team = document[teamKey].stringValue
    }
}

extension SessionUser {
    static func unknownUser() -> SessionUser {
        SessionUser(
            id: unknownUserIdKey,
            firstName: unknownUserNameKey,
            lastName: "",
            team: DittoTeam.undefined.rawValue
        )
    }
}

extension SessionUser {    
    func docDictionary() -> [String: Any?] {
        [
            dbIdKey: id,
            firstNameKey: firstName,
            lastNameKey: lastName,
            team: team
        ]
    }
}
