/*
 * Copyright (c) 2021-2023 DittoLive.
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
package live.dittolive.chat.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.liveData
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import live.ditto.DittoAttachmentFetcher
import live.ditto.DittoAttachmentToken
import live.dittolive.chat.DittoHandler
import live.dittolive.chat.conversation.Message
import live.dittolive.chat.data.DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID
import live.dittolive.chat.data.colleagueUser
import live.dittolive.chat.data.meProfile
import live.dittolive.chat.data.model.MessageUiModel
import live.dittolive.chat.data.model.Room
import live.dittolive.chat.data.model.User
import live.dittolive.chat.data.publicKey
import live.dittolive.chat.data.publicRoomTitleKey
import live.dittolive.chat.data.repository.Repository
import live.dittolive.chat.data.repository.UserPreferencesRepository
import live.dittolive.chat.profile.ProfileFragment
import java.util.UUID
import javax.inject.Inject

/**
 * View model used for storing the global app state.
 *
 * This view model is used for all screens.
 */
@HiltViewModel
class MainViewModel @Inject constructor(
    private val repository: Repository,
    private val userPreferencesRepository: UserPreferencesRepository
) : ViewModel() {

    private val _drawerShouldBeOpened = MutableStateFlow(false)
    val drawerShouldBeOpened = _drawerShouldBeOpened.asStateFlow()
    var currentUserId = MutableStateFlow<String>(" ")

    private val emptyRoom = Room(
        id = publicKey,
        name = publicRoomTitleKey,
        createdOn = Clock.System.now(),
        messagesCollectionId = DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID,
        isPrivate = false,
        collectionID = publicKey,
        createdBy = "Ditto System"
    )

    private val _currentRoom = MutableStateFlow<Room>(emptyRoom)
    val currentRoom = _currentRoom.asStateFlow()

    fun setCurrentChatRoom(newChatRoom: Room) {
        _currentRoom.value = newChatRoom
        setRoomMessagesWithUsers(newChatRoom)
    }

    /**
     * Flag for whether the profile that has been clicked is this user or another user
     */
    private val _isUserMe = MutableStateFlow(false)
    val isUserMe = _isUserMe.asStateFlow()

    /**
     * Flag for whether the user is logged in or not
     * Because in this demo app we are automatically logging in via token on launch, this is
     * initially set to true
     */
    private val _isUserLoggedIn = MutableStateFlow(true)
    val isUserLoggedIn = _isUserLoggedIn.asStateFlow()

    val initialSetupEvent = liveData {
        emit(userPreferencesRepository.fetchInitialPreferences())
    }

    val users: LiveData<List<User>> by lazy {
        repository.getAllUsers().asLiveData()
    }

    private val _dittoSdkVersion = MutableStateFlow(" ")
    val dittoSdkVersion: StateFlow<String> = _dittoSdkVersion.asStateFlow()

    val allPublicRoomsFLow: Flow<List<Room>> = repository.getAllPublicRooms()

    private fun setRoomMessagesWithUsers(chatRoom: Room) {
        // updating a flow will automatically update flows that rely on it
        repository.getAllMessagesForRoom(chatRoom)
    }

    // messages for a particular chat room
    val roomMessagesWithUsersFlow: Flow<List<MessageUiModel>> = combine(
        repository.getAllUsers(),
        repository.getAllMessagesForRoom(currentRoom.value)
    ) { users: List<User>, messages:List<Message> ->

        messages.map {
            MessageUiModel.invoke(
                message = it,
                users = users
            )
        }
    }

    private val _userData = MutableLiveData<User>()
    val userData: LiveData<User> = _userData
    private var userId: String = ""
    /**
     * This is used in the `onAttach` of the [ProfileFragment]
     * @param newUserId the id of the user who's profile was tapped on
     */
    fun setUserId(newUserId: String?) {
        if (newUserId != userId) {
            userId = newUserId ?: meProfile.userId
        }

        _isUserMe.value = userId == currentUserId.value
        _userData.value = if (userId == currentUserId.value) {
            getCurrentUser()
        } else {
            colleagueUser
        }
    }

    private suspend fun getDefaultPublicRoom(): Room {
        return repository.publicRoomForId(publicKey)
    }

    /**
     * Some setup required...
     */
    init {
        viewModelScope.launch {
            currentUserId.value =  userPreferencesRepository.fetchInitialPreferences().currentUserId
            _currentRoom.value = getDefaultPublicRoom()
        }

        val user = getCurrentUser()
        if (user?.firstName == null) {
            // temporary user initialziation - if user name hasn't been set by the user yet, we use the device name
            val firstName = "My"
            val lastName = android.os.Build.MODEL
            updateUserInfo(firstName, lastName)
        }

        _dittoSdkVersion.value = repository.getDittoSdkVersion()
    }

    fun updateUserInfo(firstName: String = this.firstName, lastName: String = this.lastName) {
        viewModelScope.launch {
            repository.saveCurrentUser(firstName, lastName)
        }
    }

    private fun getUserById(id: String): User? {
        return users.value?.find { user: User -> user.id == id }
    }

    private fun getCurrentUser() : User? {
        return getUserById(currentUserId.value)
    }

    private fun getCurrentFirstName() : String {
        val user = getCurrentUser()
        return user?.firstName ?: ""
    }

    private fun getCurrentLasttName() : String {
        val user = getCurrentUser()
        return user?.lastName ?: ""
    }

    fun onCreateNewMessageClick(messageText: String) {
        val currentMoment: Instant = Clock.System.now()
        val message = Message(
            UUID.randomUUID().toString(),
            currentMoment,
            currentRoom.value.id,
            messageText,
            "author_me",
            null,
            null
        )

        viewModelScope.launch(Dispatchers.Default) {
            repository.createMessageForRoom(message, currentRoom.value)
        }
    }

    fun getAttachment(message: Message, callback: (Any) -> Unit) {
        val fetchers: MutableMap<DittoAttachmentToken, DittoAttachmentFetcher> = mutableMapOf()
        message.attachmentToken?.let { token ->
            fetchers[token] =
                DittoHandler.ditto.store.collection(currentRoom.value.messagesCollectionId ).fetchAttachment(token, callback)
        }
    }

    fun openDrawer() {
        _drawerShouldBeOpened.value = true
    }

    fun resetOpenDrawerAction() {
        _drawerShouldBeOpened.value = false
    }

    /**
     * Edit Profile Screen State
     */
    private val _uiState = MutableStateFlow(EditProfileUiState(getCurrentFirstName(), getCurrentLasttName()))
    val uiState: StateFlow<EditProfileUiState> = _uiState.asStateFlow()

    private var firstName: String = ""
    private var lastName: String = ""

    fun updateFirstName(firstName: String) {
        this.firstName = firstName
        _uiState.value = _uiState.value.copy(
            currentFirstName = firstName
        )
    }

    fun updateLastName(lastName: String) {
        this.lastName = lastName
        _uiState.value = _uiState.value.copy(
            currentLastName = lastName
        )
    }

}

data class EditProfileUiState(
    val currentFirstName: String = "",
    val currentLastName: String = ""
)
