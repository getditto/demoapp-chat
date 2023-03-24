///
//  DittoToolsUtilities.swift
//  DittoChat
//
//  Created by Eric Turner on 1/31/23.
//®
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import DittoDataBrowser
import DittoDiskUsage
import DittoExportLogs
import DittoPresenceViewer
import DittoSwift
import SwiftUI

struct PresenceViewer: View {
    var body: some View {
        PresenceView(ditto: DittoInstance.shared.ditto)
    }
}

struct DataBrowserView: View {
    var body: some View {
        DataBrowser(ditto: DittoInstance.shared.ditto)
    }
}

struct DiskUsageViewer: View {
    var body: some View {
        DittoDiskUsageView(ditto: DittoInstance.shared.ditto)
    }
}

struct ExportLogsView: View {
    var body: some View {
        ExportLogs()
    }
}

