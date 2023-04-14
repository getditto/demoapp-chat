///
//  ErrorHandler.swift
//
//  Created by Ralf Ebert July 29, 2021
//  https://www.ralfebert.com/swiftui/generic-error-handling/



import SwiftUI

struct ErrorAlert: Identifiable {
    var id = UUID()
    var message: String
    var title: String?
    var dismissAction: (() -> Void)?
}

class ErrorHandler: ObservableObject {
    @Published var currentAlert: ErrorAlert?

    func handle(error: Error, title: String? = nil) {
        currentAlert = ErrorAlert(message: error.localizedDescription, title: title)
    }
}

struct HandleErrorsByShowingAlertViewModifier: ViewModifier {
    @StateObject var errorHandler = ErrorHandler()

    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandler)
            // Applying the alert for error handling using a background element
            // is a workaround, if the alert would be applied directly,
            // other .alert modifiers inside of content would not work anymore
            .background(
                EmptyView()
                    .alert(item: $errorHandler.currentAlert) { currentAlert in
                        Alert(
                            title: Text(currentAlert.title ?? errorTitleKey),
                            message: Text(currentAlert.message),
                            dismissButton: .default(Text(dismissTitleKey)) {
                                currentAlert.dismissAction?()
                            }
                        )
                    }
            )
    }
}

extension View {
    func withErrorHandling() -> some View {
        modifier(HandleErrorsByShowingAlertViewModifier())
    }
}
