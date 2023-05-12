///
//  UIImage+Rotation.swift
//  DittoChat
//
//  Created by Eric Turner on 3/1/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import SwiftUI

// WWDC 2021 - Meet async/await in Swift
extension UIImage {

    func attachmentThumbnail() async -> UIImage? {
        return await self.byPreparingThumbnail(ofSize: attachmentThumbnailSize)
    }
    
    var attachmentThumbnailSize: CGSize {
        // arbitrary portrait thumbnail dimensions; invert if landscape
        let edge1 = 282.0; let edge2 = 376.0
        let size = size.width > size.height
        ? CGSize(width: edge2, height: edge1)
        : CGSize(width: edge1, height: edge2)
        return size
    }
}

// John Scalo
// https://stackoverflow.com/questions/1296707/get-size-of-a-uiimage-bytes-length-not-height-and-width
extension UIImage {
    var sizeInBytes: Int {
        guard let cgImage = self.cgImage else {
            print("\(#function) ERROR: CIImage-based UIImage not supported - RETURN ZERO")
            return 0
        }
        return cgImage.bytesPerRow * cgImage.height
    }
}
