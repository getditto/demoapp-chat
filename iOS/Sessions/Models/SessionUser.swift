///
//  SessionUser.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import DittoSwift
import Foundation
/*
enum DittoTeam: CaseIterable {
    case bigPeer
    case cloudServices
    case cx
    case executive
    case federal
    case hr
    case legal
    case marketing
    case operations
    case product
    case smallPeer
    case replication
    case sales
    case transport
    case undefined

    var title: String {
        switch self {
        case .bigPeer:       return "Big Peer"
        case .cloudServices: return "Cloud Services"
        case .cx:            return "Customer Experience"
        case .executive:     return "Executive"
        case .federal:       return "Federal"
        case .hr:            return "HR"
        case .legal:         return "Legal"
        case .marketing:     return "Marketing"
        case .operations:    return "Operations"
        case .product:       return "Product"
        case .smallPeer:     return "Small Peer"
        case .replication:   return "Replication"
        case .sales:         return "Sales"
        case .transport:     return "Transport"
        case .undefined:     return "Undefined"
        }
    }
} */
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

