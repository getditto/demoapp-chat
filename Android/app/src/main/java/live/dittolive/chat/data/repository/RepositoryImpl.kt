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
import live.ditto.DittoSortDirection
import live.ditto.DittoSubscription
import live.dittolive.chat.DittoHandler.Companion.ditto
import live.dittolive.chat.conversation.Message
import live.dittolive.chat.data.DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID
import live.dittolive.chat.data.collectionIdKey
import live.dittolive.chat.data.createdByKey
import live.dittolive.chat.data.createdOnKey
import live.dittolive.chat.data.db.ChatRoomDao
import live.dittolive.chat.data.dbIdKey
import live.dittolive.chat.data.firstNameKey
import live.dittolive.chat.data.isPrivateKey
import live.dittolive.chat.data.lastNameKey
import live.dittolive.chat.data.messagesIdKey
import live.dittolive.chat.data.model.ChatRoom
import live.dittolive.chat.data.model.User
import live.dittolive.chat.data.model.toIso8601String
import live.dittolive.chat.data.nameKey
import live.dittolive.chat.data.publicKey
import live.dittolive.chat.data.publicRoomTitleKey
import live.dittolive.chat.data.publicRoomsCollectionId
import live.dittolive.chat.data.roomIdKey
import live.dittolive.chat.data.textKey
import live.dittolive.chat.data.thumbnailKey
import live.dittolive.chat.data.userIdKey
import live.dittolive.chat.data.usersKey
import java.util.UUID
import javax.inject.Inject

// Constructor-injected, because Hilt needs to know how to
// provide instances of RepositoryImpl, too.
class RepositoryImpl @Inject constructor(
    private val userPreferencesRepository: UserPreferencesRepository,
    private val chatRoomDao: ChatRoomDao
) : Repository {

    private val allMessagesForRoom: MutableStateFlow<List<Message>> by lazy {
        MutableStateFlow(emptyList())
    }

    private val allPublicRooms : MutableStateFlow<List<ChatRoom>> by  lazy {
        MutableStateFlow(emptyList())
    }



    private val allUsers: MutableStateFlow<List<User>> by lazy {
        MutableStateFlow(emptyList())
    }

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

    /**
     * Private Rooms
     */
    override val allPrivateRooms : MutableStateFlow<List<ChatRoom>> by lazy {
        MutableStateFlow(chatRoomDao.getAllPrivateRooms())
    }



    // private in-memory stores of subscriptions for rooms and messages
//    private var privateRoomSubscriptions = listOf<>() [String: DittoSubscription]()
//    private var privateRoomMessagesSubscriptions = [String: DittoSubscription]()

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

    override fun getAllMessagesForRoom(chatRoom: ChatRoom): Flow<List<Message>> {
        getAllMessagesForRoomFromDitto(chatRoom)

        return allMessagesForRoom
    }

    override fun getAllUsers(): Flow<List<User>> = allUsers

    override fun getAllPublicRooms(): Flow<List<ChatRoom>> = allPublicRooms

    override suspend fun saveCurrentUser(firstName: String, lastName: String) {
        val userID = userPreferencesRepository.fetchInitialPreferences().currentUserId
        val user = User(userID, firstName, lastName)
        addUser(user)

    }

    override suspend fun createMessageForRoom(message: Message, chatRoom: ChatRoom, attachment: DittoAttachment?) {
        val userID = userPreferencesRepository.fetchInitialPreferences().currentUserId
        val currentMoment: Instant = Clock.System.now()
        val datetimeInUtc: LocalDateTime = currentMoment.toLocalDateTime(TimeZone.UTC)
        val dateString = datetimeInUtc.toIso8601String()
        val collection = ditto.store.collection(chatRoom.messagesCollectionId)
        val doc = mapOf(
            createdOnKey to dateString,
            roomIdKey to message.roomId,
            textKey to message.text,
            userIdKey to userID,
            thumbnailKey to attachment
        )

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
            .upsert(
                mapOf(
                    dbIdKey to user.id,
                    firstNameKey to user.firstName,
                    lastNameKey to user.lastName
                )
            )
    }

    override suspend fun createRoom(name: String, isPrivate: Boolean, userId: String) {
        val roomId = UUID.randomUUID().toString()
        val messagesId = UUID.randomUUID().toString()
        var collectionId: String = publicRoomsCollectionId
        val currentMoment: Instant = Clock.System.now()
        val datetimeInUtc: LocalDateTime = currentMoment.toLocalDateTime(TimeZone.UTC)
        val dateString = datetimeInUtc.toIso8601String()
        if (isPrivate) {
            collectionId = UUID.randomUUID().toString()
        }

        val chatRoom = ChatRoom(
            id = roomId,
            name = name,
            messagesCollectionId = messagesId,
            isPrivate = isPrivate,
            collectionID = collectionId,
            createdBy = userId,
        )

        val doc = mapOf(
            dbIdKey to chatRoom.id,
            nameKey to chatRoom.name,
            messagesIdKey to chatRoom.messagesCollectionId,
            isPrivateKey to chatRoom.isPrivate,
            collectionIdKey to chatRoom.collectionID,
            createdByKey to chatRoom.createdBy,
            createdOnKey to dateString
        )


        // TODO : possibly remove this - b/c we are using Flow to keep a live update of public rooms
        addSubscriptionForRoom(chatRoom)

        ditto.let {
            ditto.store.collection(collectionId).upsert(doc)
        }
    }

    private fun addSubscriptionForRoom(chatRoom: ChatRoom) {
        if (chatRoom.isPrivate) {
            // TODO
        } else {
            val messageSubscription = ditto.store[chatRoom.messagesCollectionId].findAll().subscribe()
            // TODO : for hide / unhide public room
//            publicRoomMessagesSubscriptions[room.id] = messageSubscription
        }
    }

    // This function without room param is for qrCode join private room, where there isn't yet a room
    private fun addPrivateRoomSubscriptions(roomId: String, collectionId: String, messagesId: String) {

        ditto.let { ditto: Ditto ->
            val privateRoomCollection = ditto.store.collection(collectionId)
            val roomSubscription = privateRoomCollection.findAll().subscribe()
            val privateRoomLiveQuery: DittoLiveQuery = privateRoomCollection
                .findAll()
                .sort(createdOnKey, DittoSortDirection.Ascending)
                .observeLocal { docs, _ ->
                    val roomDocs = docs
                    val privateChatRooms = docs.map {ChatRoom(it)}
                    // TODO : insert to Room db
                }
            val messagesSubscription = ditto.store.collection(messagesId).findAll().subscribe()

            //track private room details locally

        }
    }

    override suspend fun archivePublicRoom(chatRoom: ChatRoom) {
        // TODO : implement
    }

    override suspend fun unarchivePublicRoom(chatRoom: ChatRoom) {
        // TODO : implement
    }

    override suspend fun joinPrivateRoom(qrCode: String): ChatRoom? {
        val parts = qrCode.split("\n")
        if (parts.count() != 3) {
            println("DittoService: Error - expected 3 parts to QR code: $qrCode --> RETURN")
            return null
        }

        // parse qrCode for roomId, collectionId, messagesId
        val roomId = parts[0]
        val collectionId = parts[1]
        val messagesId = parts[2]

        return privateRoomForId(roomId, collectionId, messagesId)
    }

    /**
     * Searches Ditto Mesh for a Private Room and returns it if found
     * If not found, returns a new private chat room with the supplied arguments
     * @param roomId unique ID of the chat room, also used as the primary key in Room databse
     * @param collectionId unique collection ID for this collection of a single private chat room
     * @param messagesId handle used to retrieve messages for this private chat room
     */
    override suspend fun privateRoomForId(
        roomId: String,
        collectionId: String,
        messagesId: String
    ): ChatRoom {
        val document = ditto.store.collection(collectionId).findById(roomId).exec()
        document?.let {
            val chatRoom = ChatRoom(document)
            /*
            ok, so we found the room in the mesh,
            but is it tracked locally, yet?
            if not, add it to local Room database to keep track of it
             */
            val localChatRoom = chatRoomDao.getPrivateChatRoom(chatRoom.id)
            localChatRoom?.let {
                return chatRoom
            }
            chatRoomDao.insert(chatRoom)
            return chatRoom
        }
        /*
        if we reached this point, that means Ditto Mesh does not have a private room matching the supplied params
        so we create a new chat room, store it locally, and return it
         */
        val emptyChatRoom = ChatRoom(
            id = roomId,
            name = "some private room",
            createdOn = Clock.System.now(),
            messagesCollectionId = messagesId,
            isPrivate = true,
            collectionID = collectionId,
            createdBy = "Ditto System"
        )
        chatRoomDao.insert(emptyChatRoom)
        return emptyChatRoom
    }

    override suspend fun archivePrivateRoom(chatRoom: ChatRoom) {
        // TODO : implement
    }

    override suspend fun unarchivePrivateRoom(chatRoom: ChatRoom) {
        // TODO : implement
    }

    override suspend fun deletePrivateRoom(chatRoom: ChatRoom) {
        // TODO : implement
    }

    override suspend fun saveRoom(chatRoom: ChatRoom) {
        chatRoomDao.insert(chatRoom)

    }

    private fun postInitActions() {
        updateUsersLiveData()
        getPublicRoomsFromDitto()
    }

    private fun updateUsersLiveData() {
        getAllUsersFromDitto()
    }

    private fun getAllMessagesForRoomFromDitto(chatRoom: ChatRoom) {
        ditto.let { ditto: Ditto ->
            messagesCollection = ditto.store.collection(chatRoom.messagesCollectionId)
            messagesSubscription = messagesCollection.findAll().subscribe()
            messagesLiveQuery = messagesCollection
                .findAll()
                .sort(createdOnKey, DittoSortDirection.Ascending)
                .observeLocal { docs, _ ->
                    this.messagesDocs = docs
                    allMessagesForRoom.value = docs.map { Message(it) }
                }
        }

    }

    private fun getPublicRoomsFromDitto() {
        ditto.let { ditto: Ditto ->
            publicRoomsCollection = ditto.store.collection(publicRoomsCollectionId)
            publicRoomsSubscription = publicRoomsCollection.findAll().subscribe()
            publicRoomsLiveQuery = publicRoomsCollection
                .findAll()
                .observeLocal { docs, _ ->
                    this.publicRoomsDocs = docs
                    allPublicRooms.value = docs.map { ChatRoom(it) }
                }

        }
    }

    override suspend fun publicRoomForId(roomId: String): ChatRoom {
        val document = ditto.store.collection(publicRoomsCollectionId).findById(roomId).exec()
        document?.let {
            val chatRoom = ChatRoom(document)
            return chatRoom
        }
        val emptyChatRoom = ChatRoom(
            id = publicKey,
            name = publicRoomTitleKey,
            createdOn = Clock.System.now(),
            messagesCollectionId = DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID,
            isPrivate = false,
            collectionID = publicKey,
            createdBy = "Ditto System"
        )
        return emptyChatRoom
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