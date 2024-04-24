//
//  QRCodeView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/12/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//
//  Credit to Paul Hudson
//  https://www.hackingwithswift.com/books/ios-swiftui/generating-and-scaling-up-a-qr-code
//

import SwiftUI

struct QRCodeView: View {
    let roomName: String
    let codeString: String

    var body: some View {
        NavigationView {
            VStack {
                Spacer().frame(height: 64)
                ZStack {
                    Image("thin_message_bubble")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 355, height: 355)

                    Image(uiImage: codeString.generateQRCode())
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .padding(.bottom, 36)
                }
                Spacer()
            }
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    VStack {
                        Text(roomName)
                            .font(.title)
                            .padding(.top, 48)
                        Text("Private Room")
                            .font(.subheadline)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView(
            roomName: "Cocktail Lounge",
            codeString: "\(UUID().uuidString)\n\(UUID().uuidString)"
        )
    }
}
#endif
