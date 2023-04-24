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

import Combine
import QuickLook
import SwiftUI

struct AttachmentPreview: View {
    @StateObject var viewModel: MessageBubbleVM
    @StateObject var errorHandler: ErrorHandler
    init(vm: MessageBubbleVM, errorHandler: ErrorHandler) {
        self._viewModel = StateObject(wrappedValue: vm)
        self._errorHandler = StateObject(wrappedValue: errorHandler)
    }
    
    var body: some View {
        VStack {
            if viewModel.fileURL != nil {
                PreviewController(url: viewModel.fileURL!)
            } else {
                NavigationView {
                    DittoProgressView($viewModel.fetchProgress)
                }
            }
        }
        .task {
            await viewModel.fetchAttachment(type: .largeImage)
        }
    }
}


struct PreviewController: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let url: URL
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        let navCon = UINavigationController(rootViewController: controller)
        
        let image = UIImage(systemName: xmarkCircleKey)!
        let icon = image.withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        button.primaryAction = UIAction(image: icon) { _ in dismiss() }
        
        controller.navigationItem.leftBarButtonItem = button
        
        return navCon
    }
    
    func updateUIViewController(
        _ uiViewController: UIViewController, context: Context) {}
    
    
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
//            return parent.url as NSURL
            return parent.url as QLPreviewItem
        }
    }
}
