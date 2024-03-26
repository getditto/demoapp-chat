///
//  Publishers.swift
//  DittoChat
//
//  Created by Walker Erekson on 1/12/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import Foundation
import Combine
import DittoSwift

typealias DittoQuery = (string: String, args: [String: Any?])

protocol DittoDecodable {
    init(value: [String: Any?])
}

// MARK: - Extensions of `execute`
extension DittoStore {

    // Emit with mapped objects as an array
    func executePublisher<T: DittoDecodable>(query: String, arguments: Dictionary<String, Any?>? = [:], mapTo: T.Type) -> AnyPublisher<[T], Error> {
        return Future { promise in
            Task.init {
                do {
                    let result = try await self.execute(query: query, arguments: arguments)
                    let items = result.items.compactMap { T(value: $0.value) }
                    promise(.success(items))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    // Emit with a mapped object as a single value instead of an array
    func executePublisher<T: DittoDecodable>(query: String, arguments: Dictionary<String, Any?>? = [:], mapTo: T.Type, onlyFirst: Bool) -> AnyPublisher<T?, Error> {
        return Future { promise in
            Task.init {
                do {
                    let result = try await self.execute(query: query, arguments: arguments)
                    guard let first = result.items.first else { return promise(.success(nil)) }
                    let item = T(value: first.value)
                    promise(.success(item))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - Extensions of `registerObserver`
extension DittoStore {

    // Send mapped objects as an array
    func observePublisher<T: DittoDecodable>(query: String, arguments: [String : Any?]? = nil, deliverOn queue: DispatchQueue = .main, mapTo: T.Type) -> AnyPublisher<[T], Error> {
        let subject = PassthroughSubject<[T], Error>()

        do {
            try self.registerObserver(query: query, arguments: arguments, deliverOn: queue) { result in
                let items = result.items.compactMap { T(value: $0.value) }
                subject.send(items)
            }
        } catch {
            subject.send(completion: .failure(error))
        }

        return subject.eraseToAnyPublisher()
    }

    // Send a mapped object as a single value instead of an array
    func observePublisher<T: DittoDecodable>(query: String, arguments: [String : Any?]? = nil, deliverOn queue: DispatchQueue = .main, mapTo: T.Type, onlyFirst: Bool) -> AnyPublisher<T?, Error> {
        let subject = PassthroughSubject<T?, Error>()

        do {
            try self.registerObserver(query: query, arguments: arguments, deliverOn: queue) { result in
                guard let first = result.items.first else { return subject.send(nil) }
                let item = T(value: first.value)
                subject.send(item)
            }
        } catch {
            subject.send(completion: .failure(error))
        }

        return subject.eraseToAnyPublisher()
    }
}
