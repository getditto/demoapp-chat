///
//  DittoManager.swift
//  DittoChat
//
//  Created by Erik Everson on 4/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import Combine
import DittoExportLogs
import DittoSwift
import SwiftUI

class DittoManager: ObservableObject {
    @Published var loggingOption: DittoLogger.LoggingOptions
    private static let defaultLoggingOption: DittoLogger.LoggingOptions = .debug
    private var cancellables = Set<AnyCancellable>()

    static var shared = DittoManager()
    let ditto: Ditto

    init() {
        ditto = Ditto(identity: DittoIdentity.offlinePlayground(appID: Env.DITTO_APP_ID))

        try! ditto.setOfflineOnlyLicenseToken(Env.DITTO_OFFLINE_TOKEN)

        // make sure our log level is set _before_ starting ditto.
        self.loggingOption = Self.storedLoggingOption()
        resetLogging()

        $loggingOption
            .dropFirst()
            .sink { [weak self] option in
                self?.saveLoggingOption(option)
                self?.resetLogging()
            }
            .store(in: &cancellables)

        // Add this ditto to chat so that it can use it
        DittoInstance.dittoShared = ditto

        // v4 AddWins
        do {
            try ditto.disableSyncWithV3()
        } catch let error {
            print("ERROR: disableSyncWithV3() failed with error \"\(error)\"")
        }

        // Prevent Xcode previews from syncing: non preview simulators and real devices can sync
        let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isPreview {
            try! ditto.startSync()
        }
    }
}
extension DittoManager {
    enum UserDefaultsKeys: String {
        case loggingOption = "live.ditto.CountDataFetch.userDefaults.loggingOption"
    }
}

extension DittoManager {
    fileprivate func storedLoggingOption() -> DittoLogger.LoggingOptions {
        return Self.storedLoggingOption()
    }
    // static function for use in init() at launch
    fileprivate static func storedLoggingOption() -> DittoLogger.LoggingOptions {
        if let logOption = UserDefaults.standard.object(
            forKey: UserDefaultsKeys.loggingOption.rawValue
        ) as? Int {
            return DittoLogger.LoggingOptions(rawValue: logOption)!
        } else {
            return DittoLogger.LoggingOptions(rawValue: defaultLoggingOption.rawValue)!
        }
    }

    fileprivate func saveLoggingOption(_ option: DittoLogger.LoggingOptions) {
        UserDefaults.standard.set(option.rawValue, forKey: UserDefaultsKeys.loggingOption.rawValue)
    }

    fileprivate func resetLogging() {
        let logOption = Self.storedLoggingOption()
        switch logOption {
        case .disabled:
            DittoLogger.enabled = false
        default:
            DittoLogger.enabled = true
            DittoLogger.minimumLogLevel = DittoLogLevel(rawValue: logOption.rawValue)!
            if let logFileURL = DittoLogManager.shared.logFileURL {
                DittoLogger.setLogFileURL(logFileURL)
            }
        }
    }
}
