/*
 * Copyright (c) 2023 DittoLive.
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * This project and source code may use libraries or frameworks that are
 * released under various Open-Source licenses. Use of those libraries and
 * frameworks are governed by their own individual licenses.
 *
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package live.dittolive.chat.data

/**
 * Local Database
 */
const val DATABASE_NAME = "chatroom_database"

/**
 * collection name for default public room
 */
const val DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID = "1440174b9330e430b46da939f0b04a34a40e10ac8073671156da174fef1ffaef" //"Public Room Messages Collection ID"
const val PREFERENCE_FILE_KEY = "live.dittolive.chat.dittoChatPrefFileKey"

/**
 * iOS Parity
 */
// Model Keys
const val collectionIdKey = "collectionId"
const val createdByKey = "createdBy"
const val createdOnKey = "createdOn"
const val dbIdKey = "_id"
const val firstNameKey = "firstName"
const val idKey = "id"
const val isArchivedKey = "isArchived"
const val isPrivateKey = "isPrivate"
const val lastNameKey = "lastName"
const val messagesIdKey = "messagesId"
const val messagesKey = "messages"
const val nameKey = "name"
const val privateRoomsKey = "privateRooms"
const val publicKey = "public"
const val roomIdKey = "roomId"
const val publicRoomsCollectionId = "rooms"
const val textKey = "text"
const val userIdKey = "userId"
const val userIdsKey = "userIds"
const val usersKey = "users"
const val thumbnailKey = "thumbnailImageToken"
const val metadataFilenameKey = "filename"
const val metadataFileformatKey = "fileformat"
const val metadataTimestampKey = "timestamp"
const val metadataFilesizeKey = "filesize"

// UI Keys
const val appTitleKey = "Ditto Chat"
const val cancelTitleKey = "Cancel"
const val firstNameTitleKey = "First Name"
const val lastNameTitleKey = "Last Name"
const val messageTitleKey = "Message"
const val messagesTitleKey = "Messages"
const val newRoomTitleKey = "New Room"
const val profileTitleKey  = "Profile"
const val publicRoomTitleKey = "Public Room"
const val saveChangesTitleKey = "Save Changes"
const val scanPrivateRoomTitleKey = "Scan Private Room"

// UserDefaults Keys
const val archivedPublicRoomsKey = "archivedPublicRooms"
const val publicRoomsIDArchiveKey = "publicRoomsIDArchive"
const val archivedPrivateRoomsKey = "archivedPrivateRooms"
const val privateRoomsIDArchiveKey = "privateRoomsIDArchive"

// Image Keys
const val arrowUpKey = "arrow.up"
const val messageKey = "message"
const val messageFillKey = "message.fill"
const val personCircleKey = "person.circle"
const val plusMessageFillKey = "plus.message.fill"