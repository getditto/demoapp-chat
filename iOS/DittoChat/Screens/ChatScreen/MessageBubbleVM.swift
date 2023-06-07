///
//  MessageBubbleVM.swift
//  DittoChat
//
//  Created by Eric Turner on 2/27/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Combine
import DittoSwift
import SwiftUI

class MessageBubbleVM: ObservableObject {
    @Published private(set) var thumbnailImage: Image?
    @Published var thumbnailProgress: Double = 0
    @Published var fetchProgress: Double = 0
    @Published private(set) var fileURL: URL? = nil
    @Published private(set) var message: Message
    @Published var presentDeleteAlert = false
    private let messagesId: String
    private var tmpStorage: TemporaryFile?    
    
    init(_ msg: Message, messagesId: String) {
        self.message = msg
        self.messagesId = messagesId
        
        DataManager.shared.messagePublisher(for: message.id, in: messagesId)
            .receive(on: RunLoop.main)
            .assign(to: &$message)
    }
    
    func cleanupStorage() async throws {
        if let storage = tmpStorage {
            Task {
                do {
                    try storage.deleteDirectory()
                } catch {
                    throw error
                }
            }
        }
    }
    
    func fetchAttachment(type: AttachmentType) async {
        guard let token = type == .largeImage
                ? message.largeImageToken
                : message.thumbnailImageToken
        else { return }
        
        ImageAttachmentFetcher().fetch(
            with: token,
            from: messagesId,
            onProgress: {[weak self] ratio in
                switch type {
                case .thumbnailImage:
                    self?.thumbnailProgress = ratio
                case .largeImage:
                    self?.fetchProgress = ratio
                }
            },
            onComplete: { result in
                switch result {
                case .success(let (uiImage, metadata) ):
                    
                    switch type {
                    case .thumbnailImage:
                        self.thumbnailImage = Image(uiImage: uiImage)
                    
                    case .largeImage:
                        let fname = metadata[filenameKey] ?? unnamedLargeImageFileKey
                        
                        if let tmp = try? TemporaryFile(creatingTempDirectoryForFilename: fname) {
                            self.tmpStorage = tmp
                            
                            if let _ = try? uiImage.jpegData(compressionQuality: 1.0)?.write(to: tmp.fileURL) {
                                self.fileURL = tmp.fileURL
                            } else {
                                print("ImageAttachmentFetcher.onComplete: Error writing JPG attachment data to file at path: \(tmp.fileURL.path) --> Return")
                            }                            
                        } else {
                            print("ImageAttachmentFetcher.onComplete.success ERROR creating tmpStorage")
                        }
                    }
                    
                case .failure:
                    print("MessageBubbleVM.ImageAttachmentFetcher.failure: UNKNOWN Thumbnail image Error")
                    self.thumbnailImage = Image(uiImage: UIImage(systemName: messageImageFailKey)!)
                    
                    // do nothing for large image fetch
                }
            })
    }
    
    deinit {
        if let storage = tmpStorage {
            Task {
                do {
                    try storage.deleteDirectory()
                } catch {
                    print("MessageBubbleVM.deinit: Error: \(AttachmentError.tmpStorageCleanupFail.localizedDescription)")
                }
            }
        }
    }
}

struct ImageAttachmentFetcher {
    typealias CompletionRatio = CGFloat
    typealias ImageMetadataTuple = (image:UIImage, metadata:[String:String])
    typealias ProgressHandler = (CompletionRatio) -> Void
    typealias CompletionHandler = (Result<ImageMetadataTuple, Error>) -> Void

    func fetch(with token: DittoAttachmentToken?,
               from collectionId: String,
               onProgress: @escaping ProgressHandler,
               onComplete: @escaping CompletionHandler
    ) {
        guard let token = token else { return }
        
        // Fetch the thumbnail data from Ditto, calling the progress handler to
        // report the operation's ongoing progress.
        let ditto = DittoInstance.shared.ditto
        let _ = ditto.store[collectionId].fetchAttachment(token: token) { event in
            switch event {
            case .progress(let downloadedBytes, let totalBytes):
                let percent = Double(downloadedBytes) / Double(totalBytes)
                onProgress(percent)

            case .completed(let attachment):
                do {
                    let data = try attachment.getData()
                    if let uiImage = UIImage(data: data) {
                        onComplete(.success( (image: uiImage, metadata: attachment.metadata) ))
                    }
                } catch {
                    print("\(#function) ERROR: \(error.localizedDescription)")
                    onComplete(.failure(error))
                }

            case .deleted:
                onComplete(.failure(AttachmentError.deleted))

            @unknown default:
                print("ImageFetcher.fetch(): default case - unknown condition")
                onComplete(.failure(AttachmentError.unknown("Unkown attachment error")))
            }
        }
    }
}
