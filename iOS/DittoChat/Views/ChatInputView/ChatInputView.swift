///
//  ChatInputView.swift
//  DittoChat
//
//  Created by Eric Turner on 02/20/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import SwiftUI

struct ChatInputView: View {
    @Binding var text: String
    var onSendButtonTappedCallback: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            Spacer(minLength: 12)
            HStack(alignment: .bottom) {
                ExpandingTextView(text: $text)
                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                Button {
                    onSendButtonTappedCallback?()
                } label: {
                    Image(systemName: arrowUpKey)
                        .padding(.all, 4)
                        .foregroundColor(Color.white)
                        .background(.blue)
                        .clipShape(Circle())
                }
                .padding(.bottom, 6)
                Spacer(minLength: 8)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.secondary, lineWidth: 1)
            )
            .padding(.bottom, 12)
            Spacer(minLength: 12)
        }
    }
}

#if DEBUG
struct ChatInputView_Previews: PreviewProvider {
    static var previews: some View {
        ChatInputView(text: .constant("Hellosdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfasdfasdfsdfsdfsdfsdf")){}
    }
}
#endif
