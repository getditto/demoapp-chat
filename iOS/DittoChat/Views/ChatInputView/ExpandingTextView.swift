//
//  ExpandingTextView.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/19/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//

import SwiftUI

struct ExpandingTextView: View {
    /**
     * This is a UITextView Adapter to SwiftUI
     */
    struct WrappedTextView: UIViewRepresentable {
        typealias UIViewType = UITextView

        @Binding var text: String
        let textDidChange: (UITextView) -> Void

        func makeUIView(context: Context) -> UITextView {
            let view = UITextView()
            view.isEditable = true
            view.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
            view.backgroundColor = .clear
            view.delegate = context.coordinator
            view.textContainerInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 0.0)
            return view
        }

        func updateUIView(_ uiView: UITextView, context: Context) {
            uiView.text = self.text
            DispatchQueue.main.async {
                self.textDidChange(uiView)
            }
        }

        func makeCoordinator() -> Coordinator {
            return Coordinator(text: $text, textDidChange: textDidChange)
        }

        class Coordinator: NSObject, UITextViewDelegate {
            @Binding var text: String
            let textDidChange: (UITextView) -> Void

            init(text: Binding<String>, textDidChange: @escaping (UITextView) -> Void) {
                self._text = text
                self.textDidChange = textDidChange
            }

            func textViewDidChange(_ textView: UITextView) {
                self.text = textView.text
                self.textDidChange(textView)
            }

            func textViewDidBeginEditing(_ textView: UITextView) {
                if textView.textColor == UIColor.lightGray {
                    textView.text = ""
                    textView.textColor = UIColor.black
                }
            }

            func textViewDidEndEditing(_ textView: UITextView) {
                if textView.text.isEmpty {
                    textView.text = messagesTitleKey
                    textView.textColor = UIColor.lightGray
                }
            }
        }
    }

    @Binding var text: String

    let minHeight: CGFloat = UIFont.systemFont(ofSize: UIFont.labelFontSize).lineHeight
    @State private var height: CGFloat?

    var body: some View {
        WrappedTextView(text: $text, textDidChange: self.textDidChange)
            .frame(height: height ?? minHeight)
    }

    private func textDidChange(_ textView: UITextView) {
        guard let lineHeight = textView.font?.lineHeight else { return }
        self.height = max(textView.contentSize.height, lineHeight)
    }
}

#if DEBUG
struct ExpandingTextView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandingTextView(text: .constant("foo"))
            .previewLayout(.sizeThatFits)
    }
}
#endif
