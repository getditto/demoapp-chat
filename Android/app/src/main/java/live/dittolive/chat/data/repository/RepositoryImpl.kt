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

import android.content.Context
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.datetime.*
import kotlinx.datetime.TimeZone
import live.ditto.*
import live.dittolive.chat.DittoHandler.Companion.ditto
import live.dittolive.chat.conversation.Message
import live.dittolive.chat.data.*
import live.dittolive.chat.data.model.*
import java.io.File
import java.io.InputStream
import java.util.*
import javax.inject.Inject

// Constructor-injected, because Hilt needs to know how to
// provide instances of RepositoryImpl, too.
class RepositoryImpl @Inject constructor(
    private val userPreferencesRepository: UserPreferencesRepository
): Repository {

    private val allMessages: MutableStateFlow<List<Message>> by lazy {
        MutableStateFlow(emptyList())
    }

    private val allUsers: MutableStateFlow<List<User>> by lazy {
        MutableStateFlow(emptyList())
    }

    private var numberOfUsers: Flow<Int> = MutableStateFlow(0)

    /**
     * Messages
     */
    private var messagesDocs = listOf<DittoDocument>()
    private lateinit var messagesCollection: DittoCollection
    private lateinit var messagesLiveQuery: DittoLiveQuery
    private lateinit var messagesSubscription: DittoSubscription

    /**
     * Users
     */
    private var userssDocs = listOf<DittoDocument>()
    private lateinit var usersCollection: DittoCollection
    private lateinit var usersLiveQuery: DittoLiveQuery
    private lateinit var usersSubscription: DittoSubscription

    init {
        initDatabase(this::postInitActions)
    }


    /**
     * Populates Ditto with sample messages if public chat room is empty
     */
    private fun initDatabase(postInitAction: suspend () -> Unit) {
        GlobalScope.launch {

            postInitAction.invoke()
        }
    }

    override fun getAllMessages(): Flow<List<Message>> = allMessages

    override fun getAllUsers(): Flow<List<User>> = allUsers

    override fun getNumberOfUsers(): Flow<Int> = numberOfUsers
    
    override suspend fun saveCurrentUser(firstName: String, lastName: String) {
        val userID = userPreferencesRepository.fetchInitialPreferences().currentUserId
        val user = User(userID,firstName, lastName)
        addUser(user)

    }

    /**
     * when implementing multiple rooms / public / private rooms,
     * replace `publicMessagesId` with MessagesId for the room
     */
    override suspend fun createMessage(message: Message, attachment: DittoAttachment?) {
        val userID = userPreferencesRepository.fetchInitialPreferences().currentUserId
        val currentMoment: Instant = Clock.System.now()
        val datetimeInUtc: LocalDateTime = currentMoment.toLocalDateTime(TimeZone.UTC)
        val dateString = datetimeInUtc.toIso8601String()

        val collection = ditto.store.collection(DEFAULT_PUBLIC_ROOM)
        val doc = mapOf(
            createdOnKey to dateString,
            roomIdKey to message.roomId,
            textKey to message.text,
            userIdKey to userID,
            thumbnailKey to attachment
        )

        // TODO : fetch Room - for everything not the default public room
         //TODO : update for multiple rooms
        collection.upsert(doc)
    }

    override suspend fun deleteMessage(id: Long) {
        // TODO : Implement
    }

    override suspend fun deleteMessages(messageIds: List<Long>) {
        // TODO : Implement
    }


    override suspend fun addUser(user: User) {
        ditto.store.collection(usersKey)
            .upsert(mapOf(
                dbIdKey to user.id,
                firstNameKey to user.firstName,
                lastNameKey to user.lastName
            ))
    }

    override suspend fun createRoom(name: String) {
        val roomId = UUID.randomUUID().toString()
        val messagesId = UUID.randomUUID().toString()
        ditto.let {
            // TODO : Implement upsert

        }
    }

    override suspend fun roomForId(roomId: String): Room? {

        val document = ditto.store.collection(DEFAULT_PUBLIC_ROOM).findById(roomId).exec()
        document?.let {
            // TODO : implement - for everything not the default public room
            //val room = Room(document)
        }
        return null
    }

    override suspend fun archivePublicRoom(room: Room) {
        // TODO : implement
    }

    override suspend fun unarchivePublicRoom(room: Room) {
        // TODO : implement
    }

    override suspend fun createPrivateRoom(name: String) {
        // TODO : implement
    }

    override suspend fun joinPrivateRoom(qrCode: String) {
        // TODO : implement
    }

    override suspend fun privateRoomForId(roomId: String, collectionId: String): Room? {
        // TODO : implement
        return null
    }

    override suspend fun archivePrivateRoom(room: Room) {
        // TODO : implement
    }

    override suspend fun unarchivePrivateRoom(room: Room) {
        // TODO : implement
    }

    override suspend fun deletePrivateRoom(room: Room) {
        // TODO : implement
    }

    private fun postInitActions() {
        updateMesagesLiveData()
        updateUsersLiveData()

    }

    private fun updateMesagesLiveData() {
        getAllMessagesFromDitto()
    }

    private fun updateUsersLiveData() {
        getAllUsersFromDitto()
    }

    private fun getAllMessagesFromDitto() {
        ditto.let { ditto: Ditto ->
            messagesCollection = ditto.store.collection(DEFAULT_PUBLIC_ROOM)
            messagesSubscription = messagesCollection.findAll().subscribe()
            messagesLiveQuery = messagesCollection
                .findAll()
                .sort(createdOnKey, DittoSortDirection.Ascending)
                .observeLocal { docs, _ ->

                this.messagesDocs = docs
                allMessages.value = docs.map { Message(it) }
            }
        }

    }

    override fun getDittoSdkVersion(): String {
        return ditto.sdkVersion
    }

    private fun getAllUsersFromDitto() {
        ditto.let { ditto : Ditto ->
            usersCollection = ditto.store.collection(usersKey)
            usersSubscription = usersCollection.findAll().subscribe()
            usersLiveQuery = usersCollection.findAll().observeLocal { docs, _ ->
                this.userssDocs = docs
                allUsers.value = docs.map { User(it) }
                numberOfUsers = MutableStateFlow(docs.size)
            }
        }
    }

    /**
     * Only create default Public room if user does not yet exist, i.e. first launch
     */
    private fun createDefaultPublicRoom() {
        // TODO: Implement once moving beyond single default public room

    }
}