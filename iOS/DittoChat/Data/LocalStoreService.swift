///
//  LocalStore.swift
//  DittoChat
//
//  Created by Eric Turner on 1/19/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Combine
import Foundation

class LocalStoreService: LocalDataInterface {
    private let defaults = UserDefaults.standard
    private let privateRoomsSubject: CurrentValueSubject<[Room], Never>
    private let archivedPrivateRoomsSubject: CurrentValueSubject<[Room], Never>
    private let archivedPublicRoomsSubject: CurrentValueSubject<[Room], Never>
    
    init() {
        let tmpDefaults = UserDefaults.standard
        // prime privateRoomsSubject
        var rooms = tmpDefaults.decodeRoomsFromData(Array(tmpDefaults.privateRooms.values))
        self.privateRoomsSubject = CurrentValueSubject<[Room], Never>(rooms)

        // prime archivedPrivateRoomsSubject
        rooms = tmpDefaults.decodeRoomsFromData(Array(tmpDefaults.archivedPrivateRooms.values))
        self.archivedPrivateRoomsSubject = CurrentValueSubject<[Room], Never>(rooms)

        // prime archivedPublicRoomsSubject
        rooms = tmpDefaults.decodeRoomsFromData(Array(tmpDefaults.archivedPublicRooms.values))
        self.archivedPublicRoomsSubject = CurrentValueSubject<[Room], Never>(rooms)
    }

    //MARK: Current User
    var currentUserId: String? {
        get { defaults.userId }
        set { defaults.userId = newValue }
    }
    
    var currentUserIdPublisher: AnyPublisher<String?, Never> {
        defaults.userIdPublisher
    }
    
    //MARK: Private Rooms
    var privateRoomsPublisher: AnyPublisher<[Room], Never> {
        privateRoomsSubject.eraseToAnyPublisher()
    }
    
    var archivedPrivateRoomsPublisher: AnyPublisher<[Room], Never> {
        archivedPrivateRoomsSubject.eraseToAnyPublisher()
    }

    func addPrivateRoom(_ room: Room) {
        let roomsData = addRoom(room, to: &defaults.privateRooms)
        let rooms = defaults.decodeRoomsFromData(roomsData)
        privateRoomsSubject.send(rooms)
    }
    
    func removePrivateRoom(roomId: String) {
        let roomsData = removeRoom(roomId: roomId, from: &defaults.privateRooms)
        let rooms = defaults.decodeRoomsFromData(roomsData)
        privateRoomsSubject.send(rooms)
    }
    
    func archivePrivateRoom(_ room: Room) {
        // remove from privateRooms
        var roomsData = removeRoom(roomId: room.id, from: &defaults.privateRooms)
        var rooms = defaults.decodeRoomsFromData(roomsData)
        privateRoomsSubject.send(rooms)
        
        // add to archivedPrivateRooms
        roomsData = addRoom(room, to: &defaults.archivedPrivateRooms)
        rooms = defaults.decodeRoomsFromData(roomsData)
        
        archivedPrivateRoomsSubject.send(rooms)
    }
    
    @discardableResult
    func unarchivePrivateRoom(roomId: String) -> Room? {
        guard let roomData = defaults.archivedPrivateRooms[roomId] else {
            print("LocalStoreService.\(#function): ERROR expected NON-NIL room data --> RETURN")
            return nil
        }
        let room = defaults.decodeRoomsFromData([roomData]).first!
        
        // remove from archivedPrivateRooms
        let roomsData = removeRoom(roomId: roomId, from: &defaults.archivedPrivateRooms)
        let rooms = defaults.decodeRoomsFromData(roomsData)
        
        archivedPrivateRoomsSubject.send(rooms)
        
        // add to privateRooms
        addPrivateRoom(room)
        
        return room
    }
    
    func deleteArchivedPrivateRoom(roomId: String) {
        let roomsData = removeRoom(roomId: roomId, from: &defaults.archivedPrivateRooms)
        let rooms = defaults.decodeRoomsFromData(roomsData)
        archivedPrivateRoomsSubject.send(rooms)
    }

    
    //MARK: Public Rooms
    var archivedPublicRoomsPublisher: AnyPublisher<[Room], Never> {
        archivedPublicRoomsSubject.eraseToAnyPublisher()
    }
    
    var archivedPublicRoomIDs: [String] {
        Array(defaults.archivedPublicRooms.keys)
    }

    // public rooms can always be fetched with roomId from Ditto db (assuming on-mesh);
    // we don't need them serialized here
    func archivePublicRoom(_ room: Room) {
        let roomsData = addRoom(room, to: &defaults.archivedPublicRooms)
        let rooms = defaults.decodeRoomsFromData(roomsData)
        archivedPublicRoomsSubject.send(rooms)
    }
    
    
    func unarchivePublicRoom(_ room: Room) {
        let roomsData = removeRoom(roomId: room.id, from: &defaults.archivedPublicRooms)
        let rooms = defaults.decodeRoomsFromData(roomsData)
        archivedPublicRoomsSubject.send(rooms)
    }
    
    //MARK: LocalStore Utilities
    func encodeRoom(_ room: Room) -> Data? {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(room) else {
            print("LocalStoreService.UserDefaults.\(#function): ERROR encoding room from json data")
            return nil
        }
        return jsonData
    }
    
    func addRoom(_ room: Room, to roomsMap: inout [String: Data]) -> [Data] {
        guard let jsonData = encodeRoom(room) else {
            print("LocalStoreService.UserDefaults.\(#function): ERROR expected NON-NIL room")
            return Array(roomsMap.values)
        }
        roomsMap[room.id] = jsonData
        return Array(roomsMap.values)
    }
    
    func removeRoom(roomId: String, from roomsMap: inout [String: Data]) -> [Data] {
        roomsMap.removeValue(forKey: roomId)
        return Array(roomsMap.values)
    }
}


fileprivate extension UserDefaults {
    
    @objc var privateRooms: [String: Data] {
        get {
            return object(forKey: privateRoomsKey) as? [String:Data] ?? [:]
        }
        set(value) {
            set(value, forKey: privateRoomsKey)
        }
    }
    
    var archivedPrivateRooms: [String: Data] {
        get {
            return object(forKey: archivedPrivateRoomsKey) as? [String: Data] ?? [:]
        }
        set(value) {
            set(value, forKey: archivedPrivateRoomsKey)
        }
    }
    
    var archivedPublicRooms: [String: Data] {
        get {
            return object(forKey: archivedPublicRoomsKey) as? [String: Data] ?? [:]
        }
        set(value) {
            set(value, forKey: archivedPublicRoomsKey)
        }
    }
}

fileprivate extension UserDefaults {
    
    @objc var userId: String? {
        get {
            return string(forKey: userIdKey)
        }
        set(value) {
            set(value, forKey: userIdKey)
        }
    }
    
    var userIdPublisher: AnyPublisher<String?, Never> {
        UserDefaults.standard
            .publisher(for: \.userId)
            .eraseToAnyPublisher()
    }
}

fileprivate extension UserDefaults {
    
    /* Though used by the LocalStoreService instance, this utility function extend UserDefaults
     because LocalStoreService invokes them in its init() method to initialize its private Combine
     currentValueSubjet properties with Room values, which it could not invoke on self before all
     properties were initialized.
     */
    func decodeRoomsFromData(_ roomsData: [Data]) -> [Room] {
        var rooms = [Room]()
        let decoder = JSONDecoder()
        
        for jsonData in roomsData {
            guard let room = try? decoder.decode(Room.self, from: jsonData) else {
                print("LocalStoreService.\(#function): ERROR decoding room from json data")
                continue
            }
            rooms.append(room)
        }
        return rooms
    }
}

