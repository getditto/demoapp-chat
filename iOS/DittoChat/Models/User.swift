//
//  User.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/19/22.
//

import DittoSwift
import Foundation

struct User: Identifiable, Hashable, Equatable {
    var id: String
    var firstName: String
    var lastName: String
    var fullName: String {
        firstName + " " + lastName
    }
}

extension User {
    init(document: DittoDocument) {
        self.id = document[dbIdKey].stringValue
        self.firstName = document[firstNameKey].stringValue
        self.lastName = document[lastNameKey].stringValue
    }
}

extension User {
    static func unknownUser() -> User {
        User(
            id: unknownUserIdKey,
            firstName: unknownUserNameKey,
            lastName: ""
        )
    }
}

extension User {    
    func docDictionary() -> [String: Any?] {
        [
            dbIdKey: id,
            firstNameKey: firstName,
            lastNameKey: lastName,
        ]
    }
}
