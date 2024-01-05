///
//  DittoToolsListView.swift
//
//  Created by Eric Turner on 1/31/23.
//®
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import Combine
import DittoDataBrowser
import DittoDiskUsage
import DittoExportData
import DittoExportLogs
import DittoPeersList
import DittoPresenceViewer
import DittoSwift
import SwiftUI

struct DittoToolsListView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var dittoService = DittoInstance.shared
    private let ditto = DittoInstance.shared.ditto
    
    // Export Ditto Directory
    @State private var presentExportDataShare: Bool = false
    @State private var presentExportDataAlert: Bool = false
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        NavigationView {
            List{
                Section(header: Text("Viewers")) {
                    NavigationLink(destination: DataBrowser(ditto: ditto)) {
                        DittoToolsListItem(title: "Data Browser", systemImage: "photo", color: .orange)
                    }
                    
                    NavigationLink(destination: PeersListView(ditto: ditto)) {
                        DittoToolsListItem(title: "Peers List", systemImage: "network", color: .blue)
                    }
                    
                    NavigationLink(destination: PresenceView(ditto: ditto)) {
                        DittoToolsListItem(title: "Presence Viewer", systemImage: "network", color: .pink)
                    }
                    
                    NavigationLink(destination: DittoDiskUsageView(ditto: ditto)) {
                        DittoToolsListItem(title: "Disk Usage", systemImage: "opticaldiscdrive", color: .secondary)
                    }
                }
                Section(header: Text("Exports")) {
                    NavigationLink(destination: LoggingDetailsView(loggingOption: $dittoService.loggingOption)) {
                        DittoToolsListItem(title: "Logging", systemImage: "square.split.1x2", color: .green)
                    }

                    // Export Ditto db Directory
                    // N.B. The export Logs feature is in DittoSwiftTools pkg, DittoExportLogs module,
                    // exposed in LoggingDetailsView ^^
                    Button(action: {
                        self.presentExportDataAlert.toggle()
                    }) {
                        HStack {
                            DittoToolsListItem(title: "Export Data Directory", systemImage: "square.and.arrow.up", color: .green)
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .foregroundColor(textColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .sheet(isPresented: $presentExportDataShare) {
                        ExportData(ditto: ditto)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationTitle("Ditto Tools")
            .alert("Export Ditto Directory", isPresented: $presentExportDataAlert) {
                Button("Export") {
                    presentExportDataShare = true
                }
                Button("Cancel", role: .cancel) {}

                } message: {
                    Text("Compressing log data may take a while.")
                }
            }
        
        Spacer()
    
        VStack {
            Text("SDK Version: \(ditto.sdkVersion)")
        }.padding()
    }
}


struct DittoToolsListView_Previews: PreviewProvider {
    static var previews: some View {
        DittoToolsListView()
    }
}
