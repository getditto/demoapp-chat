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
import live.ditto.DittoAttachment
import live.ditto.DittoCollection
import live.ditto.DittoDocument
import live.ditto.DittoLiveQuery
import live.ditto.DittoQueryResultItem
import live.ditto.DittoSortDirection
import live.ditto.DittoStoreObserver
import live.ditto.DittoSubscription
import live.ditto.DittoSyncSubscription
import live.dittolive.chat.DittoHandler.Companion.ditto
import live.dittolive.chat.conversation.Message
import live.dittolive.chat.data.DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID
import live.dittolive.chat.data.collectionIdKey
import live.dittolive.chat.data.createdOnKey
import live.dittolive.chat.data.dbIdKey
import live.dittolive.chat.data.firstNameKey
import live.dittolive.chat.data.lastNameKey
import live.dittolive.chat.data.model.Room
import live.dittolive.chat.data.model.User
import live.dittolive.chat.data.model.toIso8601String
import live.dittolive.chat.data.privateRoomsKey
import live.dittolive.chat.data.publicKey
import live.dittolive.chat.data.publicRoomTitleKey
import live.dittolive.chat.data.roomIdKey
import live.dittolive.chat.data.roomsKey
import live.dittolive.chat.data.textKey
import live.dittolive.chat.data.thumbnailKey
import live.dittolive.chat.data.userIdKey
import live.dittolive.chat.data.usersKey
import live.dittolive.chat.utilities.parsePrivateRoomQrCode
import live.dittolive.chat.utilities.toMap
import java.util.UUID
import javax.inject.Inject
import javax.inject.Scope
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking


// Constructor-injected, because Hilt needs to know how to
// provide instances of RepositoryImpl, too.
class RepositoryImpl @Inject constructor(
    private val userPreferencesRepository: UserPreferencesRepository
) : Repository {

    private val allMessagesForRoom: MutableStateFlow<List<Message>> by lazy {
        MutableStateFlow(emptyList())
    }

    private val allPublicRooms : MutableStateFlow<List<Room>> by  lazy {
        MutableStateFlow(emptyList())
    }

    private val allPrivateRooms : MutableStateFlow<List<Room>> by  lazy {
        MutableStateFlow(emptyList())
    }

    private val allUsers: MutableStateFlow<List<User>> by lazy {
        MutableStateFlow(emptyList())
    }

    /**
     * Messages
     */
    private var messagesDocs = listOf<DittoQueryResultItem>()
    private lateinit var messagesCollection: DittoCollection
    private lateinit var messagesLiveQuery: DittoStoreObserver
    private lateinit var messagesSubscription: DittoSyncSubscription

    /**
     * Public Rooms
     */
    private lateinit var publicRoomsCollection: DittoCollection
    private lateinit var publicRoomsSubscription: DittoSyncSubscription
    private lateinit var publicRoomsLiveQuery: DittoStoreObserver
    private var publicRoomsDocs = listOf<DittoQueryResultItem>()

    /**
     * Private Rooms
     */
    private var privateRoomsLiveQuery: DittoStoreObserver? = null
    private val privateRoomsSubscriptions: MutableList<DittoSyncSubscription> = mutableListOf()
    private val privateRoomsSubscriptionsLiveQueries: MutableList<DittoStoreObserver> = mutableListOf()

    /**
     * Users
     */
    private var userssDocs = listOf<DittoQueryResultItem>()
    private lateinit var usersCollection: DittoCollection
    private lateinit var usersLiveQuery: DittoStoreObserver
    private lateinit var usersSubscription: DittoSyncSubscription

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

    override fun getAllMessagesForRoom(room: Room): Flow<List<Message>> {
        getAllMessagesForRoomFromDitto(room)

        return allMessagesForRoom
    }

    override fun getAllUsers(): Flow<List<User>> = allUsers

    override fun getAllPublicRooms(): Flow<List<Room>> = allPublicRooms

    override fun getAllPrivateRooms(): Flow<List<Room>> = allPrivateRooms

    override suspend fun saveCurrentUser(firstName: String, lastName: String) {
        val userID = userPreferencesRepository.fetchInitialPreferences().currentUserId
        val user = User(userID, firstName, lastName)
        addUser(user)

    }

    override suspend fun createMessageForRoom(message: Message, room: Room, attachment: DittoAttachment?) {
        val userID = userPreferencesRepository.fetchInitialPreferences().currentUserId
        val currentMoment: Instant = Clock.System.now()
        val datetimeInUtc: LocalDateTime = currentMoment.toLocalDateTime(TimeZone.UTC)
        val dateString = datetimeInUtc.toIso8601String()

            //delete this
//        val collection = ditto.store.collection(room.messagesCollectionId)
//        val doc = mapOf(
//            createdOnKey to dateString,
//            roomIdKey to message.roomId,
//            textKey to message.text,
//            userIdKey to userID,
//            thumbnailKey to attachment
//        )
//
//        collection.upsert(doc)

        val newDoc = mapOf(
            createdOnKey to dateString,
            roomIdKey to message.roomId,
            textKey to message.text,
            userIdKey to userID,
            thumbnailKey to attachment
        )

        val query = "INSERT INTO COLLECTION `${room.messagesCollectionId}` (${thumbnailKey} ATTACHMENT) DOCUMENTS (:newDoc) ON ID CONFLICT DO UPDATE"
        val args = mapOf("newDoc" to newDoc, "$thumbnailKey" to attachment)

        ditto.store.execute(query, args)

    }

    override suspend fun deleteMessage(id: Long) {
        // TODO : Implement
    }

    override suspend fun deleteMessages(messageIds: List<Long>) {
        // TODO : Implement
    }


    override suspend fun addUser(user: User) {

//          delete this
//        ditto.store.collection(usersKey)
//            .upsert(
//                mapOf(
//                    dbIdKey to user.id,
//                    firstNameKey to user.firstName,
//                    lastNameKey to user.lastName
//                )
//            )

        val query = "INSERT INTO $usersKey DOCUMENTS (:newDoc) ON ID CONFLICT DO UPDATE"
        val newDoc = mapOf(
            dbIdKey to user.id,
            firstNameKey to user.firstName,
            lastNameKey to user.lastName
        )

        val args = mapOf("newDoc" to newDoc)


        ditto.store.execute(query, args)

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
        val privateRoomQrCode = parsePrivateRoomQrCode(qrCode) ?: return

        //delete this
//        val collection = ditto.store[privateRoomQrCode.collectionId]
//        privateRoomsSubscriptions.add(collection.findAll().subscribe())


        privateRoomsSubscriptions.add(ditto.sync.registerSubscription("SELECT * FROM `${privateRoomQrCode.collectionId}`"))

        //delete this
//        privateRoomsSubscriptionsLiveQueries.add(
//            collection.findById(privateRoomQrCode.roomId).observeLocal { _, _ ->
//                getPrivateRoomsFromDitto()
//            }
//        )

        privateRoomsSubscriptionsLiveQueries.add(
            ditto.store.registerObserver("SELECT * FROM `${privateRoomQrCode.collectionId}` WHERE _id = :id", mapOf("id" to privateRoomQrCode.roomId)) {
                _ ->
                getPrivateRoomsFromDitto()
            }
        )

        //delete this
//        ditto.store.collection(privateRoomsKey).upsert(privateRoomQrCode.toMap())

        val query = "INSERT INTO $privateRoomsKey DOCUMENTS (:newDoc) ON ID CONFLICT DO UPDATE"
        val args = mapOf("newDoc" to privateRoomQrCode.toMap())
        ditto.store.execute(query, args)

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

    override fun onCleared() {
        privateRoomsLiveQuery?.close()
        privateRoomsSubscriptions.forEach { it.close() }
        privateRoomsSubscriptions.clear()
        privateRoomsSubscriptionsLiveQueries.forEach { it.close() }
        privateRoomsSubscriptionsLiveQueries.clear()
    }

    private fun postInitActions() {
        updateUsersLiveData()
        getPublicRoomsFromDitto()
        getPrivateRoomsFromDitto()
    }

    private fun updateUsersLiveData() {
        getAllUsersFromDitto()
    }

    private fun getAllMessagesForRoomFromDitto(room: Room) {
        ditto.let { ditto: Ditto ->

            //delete this
//            messagesCollection = ditto.store.collection(room.messagesCollectionId)

            //delete this
//            messagesSubscription = messagesCollection.findAll().subscribe()
            messagesSubscription = ditto.sync.registerSubscription("SELECT * FROM `${room.messagesCollectionId}`")


//            messagesLiveQuery = messagesCollection
//                .findAll()
//                .sort(createdOnKey, DittoSortDirection.Ascending)
//                .observeLocal { docs, _ ->
//                    this.messagesDocs = docs
//                    allMessagesForRoom.value = docs.map { Message(it) }
//                }

            messagesLiveQuery = ditto.store.registerObserver("SELECT * FROM COLLECTION `${room.messagesCollectionId}` ($thumbnailKey ATTACHMENT) ORDER BY $createdOnKey ASC") {
                results ->
                this.messagesDocs = results.items
                allMessagesForRoom.value = results.items.map { Message(it.value) }
            }

        }

    }

    private fun getPublicRoomsFromDitto() {
        ditto.let { ditto: Ditto ->

            //delete this
//            publicRoomsCollection = ditto.store.collection(roomsKey)
//            publicRoomsSubscription = publicRoomsCollection.findAll().subscribe()

            publicRoomsSubscription = ditto.sync.registerSubscription("SELECT * FROM $roomsKey")

            //delete this
//            publicRoomsLiveQuery = publicRoomsCollection
//                .findAll()
//                .observeLocal { docs, _ ->
//                    this.publicRoomsDocs = docs
//                    allPublicRooms.value = docs.map { Room(it) }
//                }

            publicRoomsLiveQuery = ditto.store.registerObserver("SELECT * FROM $roomsKey") {
                results ->
                this.publicRoomsDocs = results.items
                allPublicRooms.value = results.items.map { Room(it.value) }
            }

        }
    }

    private fun getPrivateRoomsFromDitto() {
        ditto.let { ditto: Ditto ->
            privateRoomsLiveQuery?.close()

//            privateRoomsLiveQuery = ditto.store.collection(privateRoomsKey)
//                .findAll()
//                .observeLocal { docs, _ ->
//                    val roomsList: List<List<Room>> = docs.map { doc ->
//                        val collectionId = doc[collectionIdKey].stringValue
//
//                        ditto.store[collectionId].findAll().exec().map { Room(it) }
//                    }
//
//                    allPrivateRooms.value = roomsList.flatten()
//                }

            privateRoomsLiveQuery = ditto.store.registerObserver("SELECT * FROM \"$privateRoomsKey\"") { results ->
                val roomsList: List<List<Room>> = runBlocking {
                    results.items.map { item ->
                        val collectionId = item.value[collectionIdKey] as String
                        async {
                            ditto.store.execute("SELECT * FROM $collectionId").items.map { Room(it.value) }
                        }
                    }.map { it.await() }
                }
                allPrivateRooms.value = roomsList.flatten()
            }

        }
    }

    override suspend fun publicRoomForId(roomId: String): Room {
        //delete this
//        val document = ditto.store.collection(roomsKey).findById(roomId).exec()

        val query = "SELECT * FROM $roomsKey WHERE _id = :id"
        val args = mapOf("id" to roomId)
        val result = ditto.store.execute(query, args)

        //delete this
//        document?.let {
//            val room = Room(document)
//            return room
//        }

        if (result.items.isNotEmpty()) {
            return Room(result.items.first().value)
        }


        return Room(
            id = publicKey,
            name = publicRoomTitleKey,
            createdOn = Clock.System.now(),
            messagesCollectionId = DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID,
            isPrivate = false,
            collectionID = publicKey,
            createdBy = "Ditto System"
        )
    }

    override fun getDittoSdkVersion(): String {
        return ditto.sdkVersion
    }

    private fun getAllUsersFromDitto() {
        ditto.let { ditto: Ditto ->

            //delete this
//            usersCollection = ditto.store.collection(usersKey)
//            usersSubscription = usersCollection.findAll().subscribe()

            usersSubscription = ditto.sync.registerSubscription("SELECT * FROM $usersKey")

            //delete this
//            usersLiveQuery = usersCollection.findAll().observeLocal { docs, _ ->
//                this.userssDocs = docs
//                allUsers.value = docs.map { User(it) }
//            }

            usersLiveQuery = ditto.store.registerObserver("SElECT * FROM $usersKey") {
                results ->
                this.userssDocs = results.items
                allUsers.value = results.items.map { User(it.value) }
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