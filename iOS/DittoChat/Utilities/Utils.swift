//
//  Utils.swift
//  DittoChat
//
//  Created by Eric Turner on 12/22/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//

import Combine
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

extension DateFormatter {
    static var shortTime: DateFormatter {
        let format = DateFormatter()
        format.timeStyle = .short
        return format
    }

    static var isoDate: ISO8601DateFormatter {
        let format = ISO8601DateFormatter()
        return format
    }

    static var isoDateFull: ISO8601DateFormatter {
        let format = self.isoDate
        format.formatOptions = [.withFullDate]
        return format
    }
}

extension String {
    //  Credit to Paul Hudson
    //  https://www.hackingwithswift.com/books/ios-swiftui/generating-and-scaling-up-a-qr-code
    func generateQRCode() -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(self.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }

    func isValidInput(_ input: String) -> Bool {
        let characterLimit = 2500
        guard input.count <= characterLimit else {
            return false
        }

        let regex = try? NSRegularExpression(pattern: "\\A([\\x09\\x0A\\x0D\\x20-\\x7E]|[\\xC2-\\xDF][\\x80-\\xBF]|\\xE0[\\xA0-\\xBF][\\x80-\\xBF]|[\\xE1-\\xEC\\xEE\\xEF][\\x80-\\xBF]{2}|\\xED[\\x80-\\x9F][\\x80-\\xBF]|\\xF0[\\x90-\\xBF][\\x80-\\xBF]{2}|[\\xF1-\\xF3][\\x80-\\xBF]{3}|\\xF4[\\x80-\\x8F][\\x80-\\xBF]{2})*\\z", options: [])
        return regex?.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)) != nil
    }
}

extension String {
    func trim() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension View {
    /// Simple view wrapper of built-in utility to print to debugger console the causes of a view redraw
    /// Usage: call `printSwiftUIChanges()` inside a view element. The print output will occur every tie the view is refreshed,
    ///  identifying the change(s) that caused the redraw.
    ///
    /// Note: the output will be relative to the entire view no matter if the call is made in,  e.g., a nested VStack
    ///
    ///  Output example:
    ///   @self, @identity, _viewModel
    func printSwiftUIChanges() -> EmptyView {
        #if DEBUG
            Self._printChanges()
        #endif
        return EmptyView()
    }
}

extension Bundle {
    var appName: String {
        if let displayName: String = self.infoDictionary?["CFBundleDisplayName"] as? String {
            return displayName
        } else if let name: String = self.infoDictionary?["CFBundleName"] as? String {
            return name
        }
        return "Ditto Chat"
    }

    var appVersion: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? notAvailableLabelKey
    }

    var appBuild: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? notAvailableLabelKey
    }
}

extension CGFloat {
    @MainActor
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    @MainActor
    static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
}

/* View size capture for debugging
 https://www.fivestars.blog/articles/swiftui-share-layout-information/
 */
struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

enum KeyboardChangeEvent {
    case willShow, didShow, willHide, didHide, unchanged
}

// https://www.vadimbulavin.com/how-to-move-swiftui-view-when-keyboard-covers-text-field/
extension Publishers {
    @MainActor
    static var keyboardStatus: AnyPublisher<KeyboardChangeEvent, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { _ in KeyboardChangeEvent.willShow }

        let didShow = NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)
            .map { _ in KeyboardChangeEvent.didShow }

        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in KeyboardChangeEvent.willHide }

        let didHide = NotificationCenter.default.publisher(for: UIApplication.keyboardDidHideNotification)
            .map { _ in KeyboardChangeEvent.didHide }

        return MergeMany(willShow, didShow, willHide, didHide)
            .eraseToAnyPublisher()
    }
}
