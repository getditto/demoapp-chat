///
//  SettingsScreen.swift
//  DittoChat
//
//  Created by Eric Turner on 1/21/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import SwiftUI

struct SettingsScreen: View {
    @StateObject var viewModel: SettingsScreenVM
    @State var acceptLargeImages: Bool
    
    init() {
        self._viewModel = StateObject(wrappedValue: SettingsScreenVM())
        self.acceptLargeImages = DataManager.shared.acceptLargeImages
    }
    
    var body: some View {
        NavigationView {

            List {
                
                Section(userSettingsTitleKey) {
                    VStack(alignment: .leading) {
                        Toggle("Enable Large Images", isOn: $acceptLargeImages)
                            .onChange(of: acceptLargeImages) { accept in
                                viewModel.setLargeImagesPrefs(accept)
                            }

                        Text("Large image sync should only be enabled if all peers are known to be using WiFi.")
                            .font(.subheadline)
                            .padding(.top, 8)
                    }
                }
                
                // DittoSwiftTools
                Section {
                    NavigationLink {
                        PresenceViewer()
                    } label: {
                        Text(presenceViewerTitleKey)
                    }
                    
                    NavigationLink {
                        DataBrowserView()
                    } label: {
                        Text(dataBrowserTitleKey)
                    }
                     
                    NavigationLink {
                        DiskUsageViewer()
                    } label: {
                        Text(diskUsageTitleKey)
                    }
                    
                    Text(exportLogsTitleKey)
                        .onTapGesture {
                            viewModel.showExportLogsSheet = true
                        }
                } header: {
                    Text(dittoToolsKey)
                } footer: {
                    HStack {
                        Spacer()
                        Text(viewModel.versionFooter)
                        Spacer()
                    }
                }
                .sheet(isPresented: $viewModel.showExportLogsSheet) {
                    ExportLogsView()
                }                
                
                // Public Rooms
                if viewModel.archivedPublicRooms.count > 0 {
                    Section(archivedPublicRoomsTitleKey) {
                        // public rooms contains Room instances fetched from Ditto
                        ForEach(viewModel.archivedPublicRooms) { room in
                            NavigationLink {
                                RoomView(
                                    room: viewModel.roomForId(room.id)!,
                                    viewModel: viewModel
                                )
                            } label: {
                                Label(room.name, systemImage: messageFillKey)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(restoreTitleKey) {
                                    viewModel.unarchiveRoom(room)
                                }
                            }
                            .tint(.green)
                        }
                    }
                }

                if viewModel.unReplicatedPublicRooms.count > 0 {
                    Section(unreplicatedPublicRoomsTitleKey) {
                        /* This "unreplicated"/Archived public rooms section contains "placeholder"
                         public room instances from localStore archive (not Ditto) for which the
                         messages subscription has been canceled. As part of the public "rooms"
                         collection, the room will always be available in the Ditto db except when
                         off-mesh, in which case "unreplicated" public rooms appear here.
                         N.B.
                         Besides simply being currenly off-mesh, there is the case in which the
                         public room was created locally and archived before it could replicate. In
                         this case, "restoring" the room actually deletes it, since the room data
                         has already been evicted from the db.
                        */
                        ForEach(viewModel.unReplicatedPublicRooms) { room in
                            NavigationLink {
                                RoomView(room: room, viewModel: viewModel)
                            } label: {
                                Label(room.name, systemImage: messageFillKey)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(restoreTitleKey) {
                                    viewModel.unarchiveRoom(room)
                                }
                            }
                            .tint(.green)
                        }
                    }
                }

                // Private Rooms
                if viewModel.archivedPrivateRooms.count > 0 {
                    Section(archivedPrivateRoomsKey) {
                        ForEach(viewModel.archivedPrivateRooms) { privRoom in
                            NavigationLink {
                                RoomView(room: privRoom, viewModel: viewModel)
                            } label: {
                                Label(privRoom.name, systemImage: messageFillKey)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(restoreTitleKey) {
                                    viewModel.unarchiveRoom(privRoom)
                                }
                            }
                            .tint(.green)
                        }
                    }
                }

                if viewModel.unReplicatedPrivateRooms.count > 0 {
                    Section {
                        /* This "unreplicated/evicted" rooms section contains placeholder archived
                         rooms (stored as JSON in UserDefaults) for which messages have been evicted
                         and the room document has not been replicated by a peer.
                         
                         It is possible that a private room appearing in this section is off-mesh or
                         out of range of any peer members of the room, and therefore unable to be
                         replicated. In this case the room could be restored when in range of a peer
                         member of the room. (Note that replication will not multi-hop across
                         devices in the mesh which are not subscribed to the private room, so
                         replication will not occur until a peer member device is in range.)
                         
                         Further, if a room from this section is "restored", the placeholder room
                         instance is placed back in the privateRooms collection and will appear
                         in the rooms list (RoomsListScreen), however, the room will not contain
                         any messages until peer member replication has occurred.
                                                  
                         NOTE: The swipe-to-DELETE feature for rooms in this section is to handle
                         the case where the user creates a private room without sharing it with any
                         peer, then archives it. In this case, the room cannot be restored because
                         there are no peers with its data.
                         
                         Though possibly ambiguous to the user in the UI, without this DELETE
                         feature, there exists the possibility of an ever-increasing group of
                         orphaned private rooms without a way to remove them.

                         The DELETE operation will cause unsubscribe(), evict(), and remove()
                         on the dittoDB, however the user may be invited to join the private room
                         again by a member user/device via qrCode.
                         */
                        ForEach(viewModel.unReplicatedPrivateRooms) { privRoom in
                            NavigationLink {
                                RoomView(room: privRoom, viewModel: viewModel)
                            } label: {
                                Label(privRoom.name, systemImage: messageFillKey)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button(settingsDeleteTitleKey) {
                                    viewModel.deleteRoom(privRoom)
                                }
                            }
                            .tint(.red)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(restoreTitleKey) {
                                    viewModel.unarchiveRoom(privRoom)
                                }
                            }
                            .tint(.green)
                        }
                    } header: {
                        Text(evictedPrivateRoomsTitleKey).font(.subheadline)
                    } footer: {
                        Text("Archived private rooms appearing in this section have been evicted from the local Ditto database but may be recoverable. This device may simply not be in proximity to a peer member of the room at the moment, or it could have been archived while off-mesh or out of range of a peer.\n\nIf you swipe-from-right to RESTORE, the room will again appear in the rooms list but will not contain messages until it has been synced with a room member peer device."
                        )

                        Text("The swipe-from-left to DELETE feature is to enable removing archived private rooms which have become \"orphaned\", where all members of the private room have left, or for the case of a private room which has never been shared. These are not recoverable."
                        )
                        .foregroundColor(.red)
                    }
                    .font(.body)
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle(settingsTitleKey)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
    }
}
