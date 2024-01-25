///
//  SessionView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import SwiftUI

struct SessionView: View {
    let session: Session
    var body: some View {
        Text("\(session.title) Detail View").font(.largeTitle)
    }
}

//#Preview {
//    SessionView()
//}
