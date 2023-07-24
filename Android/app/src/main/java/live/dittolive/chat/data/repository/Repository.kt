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

package live.dittolive.chat.data.repository

import kotlinx.coroutines.flow.Flow
import live.ditto.DittoAttachment
import live.dittolive.chat.conversation.Message
import live.dittolive.chat.data.model.ChatRoom
import live.dittolive.chat.data.model.User

/**
 * Interface for communication with Ditto Layer
 */
interface Repository {

    fun getDittoSdkVersion(): String

    // rooms
    fun getAllPublicRooms(): Flow<List<ChatRoom>>

    // messages
    fun getAllMessagesForRoom(chatRoom: ChatRoom): Flow<List<Message>>
    suspend fun createMessageForRoom(message: Message, chatRoom: ChatRoom, attachment: DittoAttachment?)
    suspend fun deleteMessage(id: Long)

    suspend fun deleteMessages(messageIds: List<Long>)

    // users
    suspend fun addUser(user: User)
    fun getAllUsers(): Flow<List<User>>
    suspend fun saveCurrentUser(firstName: String, lastName: String)

    // rooms
    suspend fun createRoom(name: String, isPrivate: Boolean = false, userId: String = "Ditto System")
    suspend fun publicRoomForId( roomId: String) : ChatRoom
    suspend fun archivePublicRoom(chatRoom: ChatRoom)
    suspend fun unarchivePublicRoom(chatRoom: ChatRoom)

    // private rooms
    suspend fun joinPrivateRoom(qrCode: String): ChatRoom?
    suspend fun privateRoomForId(roomId: String, collectionId: String, messagesId: String) : ChatRoom
    suspend fun archivePrivateRoom(chatRoom: ChatRoom)
    suspend fun unarchivePrivateRoom(chatRoom: ChatRoom)
    suspend fun deletePrivateRoom(chatRoom: ChatRoom)

    suspend fun saveRoom(chatRoom: ChatRoom)

    suspend fun getAllPrivateRooms(): Flow<List<ChatRoom>>
}