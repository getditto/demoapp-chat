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
import live.dittolive.chat.conversation.Message
import live.dittolive.chat.data.colleagueUser
import live.dittolive.chat.data.meProfile
import live.dittolive.chat.data.model.MessageUiModel
import live.dittolive.chat.data.model.Room
import live.dittolive.chat.data.model.User
import live.dittolive.chat.data.repository.Repository
import live.dittolive.chat.data.repository.UserPreferencesRepository
import live.dittolive.chat.profile.ProfileFragment
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

    private val _currentChatRoomName = MutableStateFlow("public")
    val currentChatRoomName = _currentChatRoomName.asStateFlow()

    /**
     * Flag for whether the profile that has been clicked is this user or another user
     */
    private val _isUserMe = MutableStateFlow(false)
    val isUserMe = _isUserMe.asStateFlow()

    val initialSetupEvent = liveData {
        emit(userPreferencesRepository.fetchInitialPreferences())
    }

    val users: LiveData<List<User>> by lazy {
        repository.getAllUsers().asLiveData()
    }

    private val _dittoSdkVersion = MutableStateFlow(" ")
    val dittoSdkVersion: StateFlow<String> = _dittoSdkVersion.asStateFlow()

    val allPublicRoomsFLow: Flow<List<Room>> = repository.getAllPublicRooms()

    val messagesWithUsersFlow: Flow<List<MessageUiModel>> = combine(
        repository.getAllUsers(),
        repository.getAllMessages()
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

    /**
     * Some setup required...
     */
    init {
        viewModelScope.launch {
            currentUserId.value =  userPreferencesRepository.fetchInitialPreferences().currentUserId
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

    fun getUserById(id: String): User? {
        val user : User? = users.value?.find { user: User -> user.id == id }
        return user
    }

    fun getCurrentUser() : User? {
        return getUserById(currentUserId.value)
    }

    fun getCurrentFirstName() : String {
        val user = getCurrentUser()
        return user?.firstName ?: ""
    }

    fun getCurrentLasttName() : String {
        val user = getCurrentUser()
        return user?.lastName ?: ""
    }

    fun onCreateNewMessageClick(message: Message) {
        viewModelScope.launch(Dispatchers.Default) {
            repository.createMessage(message)
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
