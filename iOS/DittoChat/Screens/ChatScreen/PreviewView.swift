//
//  PreviewView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/29/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//
//  Credit to Natalia Panferova
//  https://nilcoalescing.com/blog/PreviewFilesWithQuickLookInSwiftUI/
//

import QuickLook
import SwiftUI

struct PreviewView: View {
    let fileURL: URL

    var body: some View {
        PreviewViewController(url: fileURL)
    }
}

struct PreviewViewController: UIViewControllerRepresentable {
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
        let parent: PreviewViewController

        init(parent: PreviewViewController) {
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
