//
//  EditMessageBubbleView.swift
//  DittoChat
//
//  Created by Eric Turner on 4/1/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import Combine
import DittoSwift
import SwiftUI

struct EditMessageBubbleView: View {
    @ObservedObject var viewModel: MessageEditVM

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack {
                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.editText)
                        .padding(textInsets)

                    Text(DateFormatter.shortTime.string(from: viewModel.editMessage.createdOn))
                        .font(.system(size: UIFont.smallSystemFontSize))
                        .padding(textInsets)
                }
                .background(backgroundColor)
                .foregroundColor(textColor)
                .clipShape(MessageBubbleShape(side: side))
            }
        }
        .padding(rowInsets)
    }

    private var side: MessageBubbleShape.Side {
        .right
    }

    private var backgroundColor: Color {
        return .accentColor
    }

    private var textColor: Color {
        return Color.white
    }

    private var rowInsets: EdgeInsets {
        return EdgeInsets(
            top: -4,
            leading: 80,
            bottom: 8,
            trailing: 20
        )
    }

    private var textInsets: EdgeInsets {
        EdgeInsets(top: 6, leading: 16, bottom: 4, trailing: 16)
    }
}
