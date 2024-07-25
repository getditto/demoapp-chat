//
//  Utils.swift
//  DittoChat
//
//  Created by Eric Turner on 12/22/22.
//

import Combine
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

extension DateFormatter {
    static var shortTime: DateFormatter {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }

    static var isoDate: ISO8601DateFormatter {
        let f = ISO8601DateFormatter()
        return f
    }
    
    static var isoDateFull: ISO8601DateFormatter {
        let f = Self.isoDate
        f.formatOptions = [.withFullDate]
        return f
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
    static var screenWidth: CGFloat {
        .infinity
    }
    static var screenHeight: CGFloat {
        .infinity
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
    
    static var keyboardStatus: AnyPublisher<KeyboardChangeEvent, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map {_ in KeyboardChangeEvent.willShow }
        
        let didShow = NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)
            .map {_ in KeyboardChangeEvent.didShow }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map {_ in KeyboardChangeEvent.willHide }
        
        let didHide = NotificationCenter.default.publisher(for: UIApplication.keyboardDidHideNotification)
            .map {_ in KeyboardChangeEvent.didHide }
        
        return MergeMany(willShow, didShow, willHide, didHide)
            .eraseToAnyPublisher()
    }
}
