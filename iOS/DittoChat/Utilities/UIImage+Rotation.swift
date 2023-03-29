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

/*
extension UIImage {

    // Credit to Josh Bernfeld
    // https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift/47402811#47402811
    func rotate(radians: Float) -> UIImage {
        let transform = CGAffineTransform(rotationAngle: CGFloat(radians))
        var rect = CGRect(origin: CGPoint.zero, size: self.size)
        var newSize = rect.applying(transform).size
        
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        rect = CGRect(
            x: -self.size.width/2, y: -self.size.height/2,
            width: self.size.width, height: self.size.height
        )
        self.draw(in: rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // If something went wrong return the original image
        return newImage ?? self
    }
    
    func radiansForOrientation(_ imageOrientation: Int) -> Float {
        switch imageOrientation {
        case 1:
            return Float(Angle.degrees(180).radians)
        case 2:
            return Float(Angle.degrees(270).radians)
        case 3:
            return Float(Angle.degrees(90).radians)
        default:
            return Float(Angle.degrees(0).radians)
        }
    }
}

extension UIImage {
    
    // credit to Abhijeet Rai
    // https://stackoverflow.com/questions/40175160/exif-data-read-and-write
    /* legacy/outdated note for png image format support, updated to jpeg:
     This utility is currently unused but not deleted yet. The message attachment feature is
     currently sharing png image data, however EXIF data from the below function does not include
     image orientation for png images; and extracting jpeg data from the UIImage always returns the
     same value for orientation, which is useless for informing how to rotate an image for display.
     */
    func getExifData() -> NSDictionary? {
        var exifData: CFDictionary? = nil
        if let data = self.jpegData(compressionQuality: 1.0) {
//        if let data = self.pngData() {
            data.withUnsafeBytes {
                let bytes = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
                if let cfData = CFDataCreate(kCFAllocatorDefault, bytes, data.count),
                    let source = CGImageSourceCreateWithData(cfData, nil) {
                    exifData = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
                }
            }
        }
        return exifData as NSDictionary?
    }
}

extension UIImage {
   
    enum ImageFormat: String {
        case png, jpg
    }
    // Credit to fewlinesofcode
    // https://stackoverflow.com/questions/53780468/reduce-the-file-size-of-png-image
    func downsample(to size: CGSize, format: ImageFormat = .jpg, scale: CGFloat? = nil) async -> UIImage {
        var returnImg = self
        let scale = scale != nil ? scale! : self.scale
        print("UIImage.\(#function) - SCALE set to \(scale)")
        
        var imgData: Data?
        switch format {
        case .jpg:
            imgData = self.jpegData(compressionQuality: 1)
        case .png:
            imgData = self.pngData()
        }
        
        guard let data = imgData else {
            print("UIImage.downsample() - Error accessing data from image for format \(format.rawValue) --> RETURN orig image")
            return returnImg
        }
        
        data.withUnsafeBytes {
            let bytes = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
            if let cfData = CFDataCreate(kCFAllocatorDefault, bytes, data.count),
               let source = CGImageSourceCreateWithData(cfData, nil) {
                let maxDimensionInPixels = max(size.width, size.height) * scale
                let downsampleOptions =
                        [kCGImageSourceCreateThumbnailFromImageAlways: true,
                        kCGImageSourceShouldCacheImmediately: true,
                        kCGImageSourceCreateThumbnailWithTransform: true,
                        kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
                if let downsampledImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) {
                    returnImg = UIImage(cgImage: downsampledImage)
                } else {
                    print("UIImage.downsample() - Error: downsample image Failed")
                }
            }
        }
        
        print("\(#function): return .\(format.rawValue) image of size \(returnImg.size) in \(returnImg.sizeInBytes) bytes")// / 1000)KB")
        return returnImg
    }
}

// https://www.advancedswift.com/resize-uiimage-no-stretching-swift/
extension UIImage {
    
    func scale(by scaleFactor: CGFloat) -> UIImage {
        print("\(#function) called with scaleFactor: \(scaleFactor)")
        
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        print("\(#function) scaledImageSize: \(scaledImageSize)  of original image.size \(self.size)")

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        print("\(#function): return image of size \(scaledImage.size) in \(scaledImage.sizeInBytes) bytes")// / 1000)KB")
        return scaledImage
    }

    
    func scaleToSize(_ targetSize: CGSize) -> UIImage {
        print("\(#function) called with targetSize: \(targetSize)")
        
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        print("\(#function) widthRatio: \(widthRatio) _ heightRatio: \(heightRatio)")
        
        let scaleFactor = min(widthRatio, heightRatio)
        print("\(#function) scaleFactor: \(scaleFactor)")
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        print("\(#function) scaledImageSize: \(scaledImageSize)")

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        print("\(#function): return image of size \(scaledImage.size) in \(scaledImage.sizeInBytes) bytes")// / 1000)KB")
        return scaledImage
    }
}
*/
