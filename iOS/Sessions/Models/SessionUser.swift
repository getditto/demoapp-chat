///
//  SessionsUser.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import DittoSwift
import Foundation

@Observable class UserWrapper: Identifiable {
    var user: SessionsUser
    var isSelected = false
    init(_ usr: SessionsUser) { user = usr }
    var id: String { user.id }    
    var firstName: String { user.firstName }
    var lastName: String { user.lastName }
    var fullName: String { user.fullName }
    var team: String { user.team }
    var imgAttachmentToken: DittoAttachmentToken?
}

// tmp: team collection in SessionsManager
//enum DittoTeam: String, Codable, CaseIterable {
//    case bigPeer       = "Big Peer"
//    case cloudServices = "Cloud Services"
//    case cx            = "Customer Experience"
//    case executive     = "Executive"
//    case federal       = "Federal"
//    case hr            = "HR"
//    case legal         = "Legal"
//    case marketing     = "Marketing"
//    case operations    = "Operations"
//    case product       = "Product"
//    case smallPeer     = "Small Peer"
//    case replication   = "Replication"
//    case sales         = "Sales"
//    case transport     = "Transport"
//    case undefined     = "Undefined"
//}

struct SessionsUser: Identifiable, Hashable, Equatable {
    var id: String
    var firstName: String
    var lastName: String
    var fullName: String {
        firstName + " " + lastName
    }
    var team: String
    var imgAttachmentToken: DittoAttachmentToken?
}

extension SessionsUser {
    init(document: DittoDocument) {
        id = document[dbIdKey].stringValue
        firstName = document[firstNameKey].stringValue
        lastName = document[lastNameKey].stringValue
        team = document[teamKey].stringValue
        imgAttachmentToken = document[largeImageTokenKey].attachmentToken
    }
}

extension SessionsUser {
    static func unknownUser() -> SessionsUser {
        SessionsUser(
            id: unknownUserIdKey,
            firstName: unknownUserNameKey,
            lastName: "",
            team: undefinedTypeKey//DittoTeam.undefined.rawValue
        )
    }
}

extension SessionsUser {    
    func docDictionary() -> [String: Any?] {
        [
            dbIdKey: id,
            firstNameKey: firstName,
            lastNameKey: lastName,
            teamKey: team,
            imgAttachmentTokenKey: imgAttachmentToken
        ]
    }
}
