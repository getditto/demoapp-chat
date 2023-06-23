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

import android.content.ContentResolver
import android.content.Context
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.core.net.toFile
import androidx.lifecycle.*
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import hilt_aggregated_deps._dagger_hilt_android_internal_modules_ApplicationContextModule
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import live.ditto.DittoAttachment
import live.ditto.DittoAttachmentFetchEvent
import live.dittolive.chat.DittoHandler
import live.dittolive.chat.conversation.Message
import live.dittolive.chat.data.DEFAULT_PUBLIC_ROOM
import live.dittolive.chat.data.colleagueProfile
import live.dittolive.chat.data.colleagueUser
import live.dittolive.chat.data.meProfile
import live.dittolive.chat.data.model.MessageUiModel
import live.dittolive.chat.data.model.User
import live.dittolive.chat.data.model.toIso8601String
import live.dittolive.chat.data.repository.Repository
import live.dittolive.chat.data.repository.RepositoryImpl
import live.dittolive.chat.data.repository.UserPreferencesRepository
import live.dittolive.chat.profile.ProfileFragment
import live.dittolive.chat.profile.ProfileScreenState
import java.io.File
import java.io.FileInputStream
import java.io.InputStream
import javax.inject.Inject

/**
 * View model used for storing the global app state.
 *
 * This view model is used for all screens.
 */
@HiltViewModel
class MainViewModel @Inject constructor(
    @ApplicationContext private val context: Context,
    private val repository: Repository,
    private val userPreferencesRepository: UserPreferencesRepository
) : ViewModel() {

    private val _drawerShouldBeOpened = MutableStateFlow(false)
    val drawerShouldBeOpened = _drawerShouldBeOpened.asStateFlow()
    var currentUserId = MutableStateFlow<String>(" ")


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

    fun uriToInputStream(uri: Uri): InputStream? {
        val contentResolver: ContentResolver = context.contentResolver

        return when {
            uri.scheme == ContentResolver.SCHEME_FILE -> {
                // Handle file scheme (e.g., "file://")
                val file = File(uri.path)
                file.inputStream()
            }
            uri.scheme == ContentResolver.SCHEME_CONTENT -> {
                // Handle content scheme (e.g., "content://")
                contentResolver.openInputStream(uri)
            }
            else -> null
        }
    }

    fun onCreateNewMessageClick(message: Message) {
        viewModelScope.launch(Dispatchers.Default) {
            if (message.photoUri == null) {
                repository.createMessage(message, null)
            } else {
                // get context
                GlobalScope.launch(Dispatchers.IO) {
                    val inputStream = uriToInputStream(message.photoUri)
                    if (inputStream != null) {
                        val currentMoment: Instant = Clock.System.now()
                        val timestamp = currentMoment.toLocalDateTime(TimeZone.UTC).toIso8601String()

                        val collection = DittoHandler.ditto.store.collection(DEFAULT_PUBLIC_ROOM)
                        val attachment = collection.newAttachment(inputStream, mapOf(
                            "filename" to message.userId + "_thumbnail_"+ timestamp + ".jpg",
                            "fileformat" to ".jpg",
                            "timestamp" to timestamp,
                            "filesize" to "1000"
                        ))
                        repository.createMessage(message, attachment)
                    }
                }
            }
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
