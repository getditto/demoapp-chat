//
//  AvatarView.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/18/22.
//

import SwiftUI

struct AvatarView: View {
    var radius: CGFloat = 10

    var body: some View {
        Image("sample_avatar")
            .clipShape(Circle())
            .shadow(radius: radius)
    }
}

#if DEBUG
struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView()
    }
}
#endif
