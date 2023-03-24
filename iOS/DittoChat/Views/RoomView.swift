///
//  RoomView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/28/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import SwiftUI

struct RoomView: View {
    let room: Room
    @ObservedObject var viewModel: SettingsScreenVM

    var body: some View {
        Spacer().frame(height: 44)

        RoomDetailsView(room: room, viewModel: viewModel)
            .navigationBarTitle(room.name)
            .navigationBarTitleDisplayMode(.inline)

        Spacer()
    }
}

//struct RoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomView()
//    }
//}
