///
//  PreviewView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/29/23.
//
//  Credit to Natalia Panferova
//  https://nilcoalescing.com/blog/PreviewFilesWithQuickLookInSwiftUI/
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import QuickLook
import SwiftUI

struct PreviewView: View {
    let fileURL: URL
    
    var body: some View {
        PreviewController(url: fileURL)
    }
}

struct PreviewController: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: QLPreviewController, context: Context) {}
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: QLPreviewControllerDataSource {
        
        let parent: PreviewController
        
        init(parent: PreviewController) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            return parent.url as NSURL
        }
    }
}
