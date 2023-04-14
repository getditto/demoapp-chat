///
//  DocumentPickerView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/29/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: View {
    
    var body: some View {
        DocumentPickerController()
    }
}

struct DocumentPickerController: UIViewControllerRepresentable {
    
//    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPickerController>) -> some UIDocumentPickerViewController {
    func makeUIViewController(context: Context) ->  UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [.pdf]
//        let picker = UIDocumentPickerViewController(documentTypes: [], in: .open)
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPickerController>) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerController
        init(parent: DocumentPickerController) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            for url in urls {
                print("DocumentPickerControllerDelegate: urls: \(url)")
                
                // Start accessing a security-scoped resource.
                guard url.startAccessingSecurityScopedResource() else {
                    // Handle the failure here.
                    print("Accessing Security Scoped Resource Error!")
                    return
                }
                
                do {
                    let _ = try Data.init(contentsOf: url)
                    print("RECEIVED DATA from file at url: \(url.path)")
                    // You will have data of the selected file
                }
                catch {
                    print(error.localizedDescription)
                }
                
                // Make sure you release the security-scoped resource when you finish.
                do { url.stopAccessingSecurityScopedResource() }
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true, completion: nil)
        }
    }

}

struct DocumentPicker_Previews: PreviewProvider {
    static var previews: some View {
        DocumentPickerController()
    }
}
