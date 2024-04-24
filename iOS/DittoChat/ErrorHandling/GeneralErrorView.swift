//
//  GeneralErrorView.swift
//  DittoChat
//
//  Created by Eric Turner on 3/29/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//

import SwiftUI

struct GeneralErrorView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    let message: String

    var body: some View {
        VStack {
            Text("Oops!...")
                .font(.largeTitle)
                .padding(24)

            Text(message)
                .padding(16)
                .multilineTextAlignment(.center)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: xmarkCircleKey)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 2)
                .frame(width: .screenWidth * 0.8, height: .screenHeight * 0.8, alignment: .center)
        )
    }

    var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.4) : Color.accentColor
    }
}

#if DEBUG
struct GeneralErrorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GeneralErrorView(message: "Hello, world!")
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
