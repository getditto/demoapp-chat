//
//  CheckboxButton.swift
//  DittoChat
//
//  Created by Eric Turner on 1/11/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import SwiftUI

public struct CheckboxButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isChecked: Bool
    public var size: CGSize
    public var action: ((Bool) -> Void)?

    public init(isChecked: Binding<Bool>,
                size: CGSize = CGSize(width: 20, height: 20),
                action: ((Bool) -> Void)? = nil
    ) {
        self._isChecked = isChecked
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: {
            isChecked.toggle()
            if let action = action { action(isChecked) }
        }) {
            Image(systemName: checkmarkKey)
                .imageScale(.small)
                .frame(width: size.width, height: size.height)
                .background(Color(UIColor.systemBackground))
                .foregroundColor(
                    isChecked ? (colorScheme == .dark ? Color.white : Color.black) : Color.clear
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(
                            colorScheme == .dark ? Color.white : Color.black,
                            lineWidth: 2
                        )
                )
        }
    }

    public var width: CGFloat { get { return size.width } }
    public var height: CGFloat { get { return size.height } }
}

#if DEBUG
struct CheckboxButton_Previews: PreviewProvider {
    @State var isChecked = false
    static var previews: some View {
        Group {
            CheckboxButton(isChecked: .constant(true))
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
