///
//  CustomErrors.swift
//  DittoChat
//
//  Created by Eric Turner on 3/27/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Foundation

public enum AppError: Error {
    case featureUnavailable(_ msg: String = "")
    case qrCodeFail
    case unknown(_ msg: String = "")
}

extension AppError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .featureUnavailable(let msg):
            if !msg.isEmpty {
                return msg
            }
            return "Feature not available"
        case .qrCodeFail:
            return "QR code failed to generate for unknown reasons"
        case .unknown(let msg):
            if !msg.isEmpty {
                return msg
            }
            return "An unknown error occurred"
        }
    }
}
extension AppError: LocalizedError {
    public var errorDescription: String? {
        self.description
    }
}


public enum AttachmentError: Error {
    case createFail
    case deleted
    case dittoDataFail(_ msg: String)
    case iCloudLibraryImageFail
    case imageDataFail
    case libraryImageFail
    case messageDocNotFound(msgId: String)
    case thumbnailCreateFail
    case tmpStorageCreateFail
    case tmpStorageWriteFail
    case tmpStorageCleanupFail
    case unknown(_ msg: String = "")
}

extension AttachmentError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .createFail:
            return "Error updating attachment"
        case .deleted:
            return "Attachment deleted"
        case .dittoDataFail(_):
            return "Attachment data fetch from Ditto failed"
        case .iCloudLibraryImageFail:
            return "Error accessing image from Photos. This can occur when Bluetooth is the only transport and the image is not completely synced by iCloud."
        case .imageDataFail:
            return "Unknown error occurred initializing image from data"
        case .libraryImageFail:
            return "Unknown error accessing image from Photos"
        case .messageDocNotFound(let msgId):
            return "No document found for message document with id: \(msgId)"
        case .thumbnailCreateFail:
            return "Error creating thumbnail image"
        case .tmpStorageCreateFail:
            return "Error creating tmp storage directory"
        case .tmpStorageWriteFail:
            return "Error writing attachment data to file"
        case .tmpStorageCleanupFail:
            return "Error deleting tmp storage directory"
        case .unknown(let msg):
            if !msg.isEmpty {
                return msg
            }
            return "An unknown error occurred"
        }
    }
}

extension AttachmentError: LocalizedError {
    public var errorDescription: String? {
        self.description
    }
}

enum AttachmentType: String, CustomStringConvertible {
    case thumbnailImage
    case largeImage
    
    var description: String {
        switch self {
        case .thumbnailImage:
            return "thumbnail"
        case .largeImage:
            return "large"
        }
    }
}
