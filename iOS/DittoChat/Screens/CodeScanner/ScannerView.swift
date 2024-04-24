//
//  ScannerView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/12/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import CodeScanner
import SwiftUI

struct ScannerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isShowingScanner = false
    @State private var scanSuccess: Bool = false
    @State private var scanFailed: Bool = false
    var successAction: (String) -> Void = { _ in }
    var failAction: (String) -> Void = { _ in }
    var scanError: ScanError?

    var body: some View {
        VStack {
            CodeScannerView(codeTypes: [.qr], completion: handleScan)
        }
        .alert("Success!", isPresented: $scanSuccess, actions: {
            Button("Dismiss", role: .cancel) { dismiss() }
        })
        .alert(scanFailureMessage(), isPresented: $scanFailed) {
            Button("Dismiss", role: .cancel) { dismiss() }
        }
    }

    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            self.scanSuccess = true
            successAction(result.string)
        case .failure(let error):
            self.scanFailed = true
            failAction(error.errorMessage)
        }
    }

    private func scanFailureMessage() -> String {
        let msg = "Scan Failed"
        guard let errMsg = scanError?.errorMessage else {
            return msg
        }
        return msg + "\n" + errMsg
    }
}

extension ScanError {
    var errorMessage: String {
        switch self {
        case .badInput:
            return "The camera could not be accessed"
        case .badOutput:
            return "The camera was not capable of scanning the requested codes"
        case .initError(_:):
            return "Code scanner initialization failed"
        case .permissionDenied:
            return "Permission to use camera for scanning denied. Please enable permission in Settings"
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
    }
}
