///
//  PresentersView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/25/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import SwiftUI

struct SelectedUsersView: View {
    @State var selectedUsers: SelectedUsers

    init(type: SelectedUsersType, session: ObservableSession) {
        selectedUsers = type == .presenters ? session.allPresenters : session.allAttendees
    }
    
    var body: some View { 
        NavigationView {
            List {
                ForEach(selectedUsers) { usr in
                    Button {
                        usr.isSelected.toggle()
                    } label: {
                        HStack {
                            Text(usr.fullName).foregroundColor(.primary)
                            
                            Spacer()
                            
                            if usr.isSelected {
                                Image(systemName: checkmarkKey)
                                    .font(.body)
                            }
                        }                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

#Preview {
    SelectedUsersView(type: .presenters, session: ObservableSession())
}
