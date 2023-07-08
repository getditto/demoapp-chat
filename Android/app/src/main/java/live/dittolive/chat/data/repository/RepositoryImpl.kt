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

import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import live.ditto.Ditto
import live.ditto.DittoCollection
import live.ditto.DittoDocument
import live.ditto.DittoLiveQuery
import live.ditto.DittoSortDirection
import live.ditto.DittoSubscription
import live.dittolive.chat.DittoHandler.Companion.ditto
import live.dittolive.chat.conversation.Message
import live.dittolive.chat.data.DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID
import live.dittolive.chat.data.createdOnKey
import live.dittolive.chat.data.dbIdKey
import live.dittolive.chat.data.firstNameKey
import live.dittolive.chat.data.lastNameKey
import live.dittolive.chat.data.model.Room
import live.dittolive.chat.data.model.User
import live.dittolive.chat.data.model.toIso8601String
import live.dittolive.chat.data.publicKey
import live.dittolive.chat.data.publicRoomTitleKey
import live.dittolive.chat.data.roomIdKey
import live.dittolive.chat.data.roomsKey
import live.dittolive.chat.data.textKey
import live.dittolive.chat.data.userIdKey
import live.dittolive.chat.data.usersKey
import java.util.UUID
import javax.inject.Inject

// Constructor-injected, because Hilt needs to know how to
// provide instances of RepositoryImpl, too.
class RepositoryImpl @Inject constructor(
    private val userPreferencesRepository: UserPreferencesRepository
) : Repository {

    private val allMessages: MutableStateFlow<List<Message>> by lazy {
        MutableStateFlow(emptyList())
    }

    private val allMessagesForRoom: MutableStateFlow<List<Message>> by lazy {
        MutableStateFlow(emptyList())
    }

    private val allPublicRooms : MutableStateFlow<List<Room>> by  lazy {
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
     * Rooms
     */
    private lateinit var publicRoomsCollection: DittoCollection
    private lateinit var publicRoomsSubscription: DittoSubscription
    private lateinit var publicRoomsLiveQuery: DittoLiveQuery
    private var publicRoomsDocs = listOf<DittoDocument>()

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
            // Prepopulate messasges
            // TODO : Implement
            // TODO : pre-pend dummy data

            postInitAction.invoke()
        }
    }

    override fun getAllMessages(): Flow<List<Message>> = allMessages

    override fun getAllMessagesForRoom(room: Room): Flow<List<Message>> {
        getAllMessagesForRoomFromDitto(room)

        return allMessagesForRoom
    }

    override fun getAllUsers(): Flow<List<User>> = allUsers

    override fun getNumberOfUsers(): Flow<Int> = numberOfUsers

    override fun getAllPublicRooms(): Flow<List<Room>> = allPublicRooms

    override suspend fun saveCurrentUser(firstName: String, lastName: String) {
        val userID = userPreferencesRepository.fetchInitialPreferences().currentUserId
        val user = User(userID, firstName, lastName)
        addUser(user)

    }

    override suspend fun createMessageForRoom(message: Message, room: Room) {
        val userID = userPreferencesRepository.fetchInitialPreferences().currentUserId
        val currentMoment: Instant = Clock.System.now()
        val datetimeInUtc: LocalDateTime = currentMoment.toLocalDateTime(TimeZone.UTC)
        val dateString = datetimeInUtc.toIso8601String()

        // TODO : fetch Room - for everything not the default public room
        ditto.store.collection(room.messagesCollectionId)
            .upsert(
                mapOf(
                    createdOnKey to dateString,
                    roomIdKey to message.roomId,
                    textKey to message.text,
                    userIdKey to userID
                )
            )
    }

    override suspend fun deleteMessage(id: Long) {
        // TODO : Implement
    }

    override suspend fun deleteMessages(messageIds: List<Long>) {
        // TODO : Implement
    }


    override suspend fun addUser(user: User) {
        ditto.store.collection(usersKey)
            .upsert(
                mapOf(
                    dbIdKey to user.id,
                    firstNameKey to user.firstName,
                    lastNameKey to user.lastName
                )
            )
    }

    override suspend fun createRoom(name: String) {
        val roomId = UUID.randomUUID().toString()
        val messagesId = UUID.randomUUID().toString()
        ditto.let {
            // TODO : Implement upsert

        }
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
        getPublicRoomsFromDitto()
    }

    private fun updateMesagesLiveData() {
        getAllMessagesForDefaultPublicRoomFromDitto()
    }

    private fun updateUsersLiveData() {
        getAllUsersFromDitto()
    }

    private fun getAllMessagesForDefaultPublicRoomFromDitto() {
        ditto.let { ditto: Ditto ->
            messagesCollection = ditto.store.collection(DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID)
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

    private fun getAllMessagesForRoomFromDitto(room: Room) {
        ditto.let { ditto: Ditto ->
            messagesCollection = ditto.store.collection(room.messagesCollectionId)
            messagesSubscription = messagesCollection.findAll().subscribe()
            messagesLiveQuery = messagesCollection
                .findAll()
                .sort(createdOnKey, DittoSortDirection.Ascending)
                .observeLocal { docs, _ ->
                    this.messagesDocs = docs
                    allMessagesForRoom.value = docs.map { Message(it) }
                    allMessages.value = docs.map { Message(it) } // DEBUG
                }
        }

    }

    private fun getPublicRoomsFromDitto() {
        ditto.let { ditto: Ditto ->
            publicRoomsCollection = ditto.store.collection(roomsKey)
            publicRoomsSubscription = publicRoomsCollection.findAll().subscribe()
            publicRoomsLiveQuery = publicRoomsCollection
                .findAll()
                .observeLocal { docs, _ ->
                    this.publicRoomsDocs = docs
                    allPublicRooms.value = docs.map { Room(it) }
                }

        }
    }

    override suspend fun publicRoomForId(roomId: String): Room {
        val document = ditto.store.collection(roomsKey).findById(roomId).exec()
        document?.let {
            val room = Room(document)
            return room
        }
        val emptyRoom = Room(
            id = publicKey,
            name = publicRoomTitleKey,
            createdOn = Clock.System.now(),
            messagesCollectionId = DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID,
            isPrivate = false,
            collectionID = publicKey,
            createdBy = "Ditto System"
        )
        return emptyRoom
    }

    override fun getDittoSdkVersion(): String {
        return ditto.sdkVersion
    }

    private fun getAllUsersFromDitto() {
        ditto.let { ditto: Ditto ->
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