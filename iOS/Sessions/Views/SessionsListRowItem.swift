///
//  SessionsListRowItem.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import SwiftUI

struct SessionsListRowItem: View {
    let session: Session
    init(_ sesh: Session) { 
        session = sesh 
    }
    
    var body: some View {
        Text(session.title)
    }
}

//#Preview {
//    SessionsListRowItem()
//}
