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
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.asLiveData
import androidx.lifecycle.liveData
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import live.ditto.DittoAttachmentFetcher
import live.ditto.DittoAttachmentToken
import live.dittolive.chat.DittoHandler
import live.dittolive.chat.conversation.Message
import live.dittolive.chat.data.DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID
import live.dittolive.chat.data.colleagueUser
import live.dittolive.chat.data.meProfile
import live.dittolive.chat.data.metadataFileformatKey
import live.dittolive.chat.data.metadataFilenameKey
import live.dittolive.chat.data.metadataFilesizeKey
import live.dittolive.chat.data.metadataTimestampKey
import live.dittolive.chat.data.model.MessageUiModel
import live.dittolive.chat.data.model.ChatRoom
import live.dittolive.chat.data.model.User
import live.dittolive.chat.data.model.toIso8601String
import live.dittolive.chat.data.publicKey
import live.dittolive.chat.data.publicRoomTitleKey
import live.dittolive.chat.data.repository.Repository
import live.dittolive.chat.data.repository.UserPreferencesRepository
import live.dittolive.chat.profile.ProfileFragment
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.UUID
import javax.inject.Inject

/**
 * View model used for storing the global app state.
 *
 * This view model is used for all screens.
 */
@HiltViewModel
class MainViewModel @Inject constructor(
    @ApplicationContext private val appContext: Context,
    private val repository: Repository,
    private val userPreferencesRepository: UserPreferencesRepository
) : ViewModel() {

    private val _drawerShouldBeOpened = MutableStateFlow(false)
    val drawerShouldBeOpened = _drawerShouldBeOpened.asStateFlow()
    var currentUserId = MutableStateFlow<String>(" ")

    private val emptyChatRoom = ChatRoom(
        id = publicKey,
        name = publicRoomTitleKey,
        createdOn = Clock.System.now(),
        messagesCollectionId = DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID,
        isPrivate = false,
        collectionID = publicKey,
        createdBy = "Ditto System"
    )

    private val _currentChatRoom = MutableStateFlow<ChatRoom>(emptyChatRoom)
    val currentRoom = _currentChatRoom.asStateFlow()

    fun setCurrentChatRoom(newChatChatRoom: ChatRoom) {
        _currentChatRoom.value = newChatChatRoom
        setRoomMessagesWithUsers(newChatChatRoom)
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

    private val users: LiveData<List<User>> by lazy {
        repository.getAllUsers().asLiveData()
    }

    private val _dittoSdkVersion = MutableStateFlow(" ")
    val dittoSdkVersion: StateFlow<String> = _dittoSdkVersion.asStateFlow()

    val allPublicRoomsFLow: Flow<List<ChatRoom>> = repository.getAllPublicRooms()

    private fun setRoomMessagesWithUsers(chatRoom: ChatRoom) {
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

    private suspend fun getDefaultPublicRoom(): ChatRoom {
        return repository.publicRoomForId(publicKey)
    }

    /**
     * Some setup required...
     */
    init {
        viewModelScope.launch {
            currentUserId.value =  userPreferencesRepository.fetchInitialPreferences().currentUserId
            _currentChatRoom.value = getDefaultPublicRoom()
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

    private fun downsampleImageFromUri(contentResolver: ContentResolver, uri: Uri, targetWidth: Int = 282, targetHeight: Int = 376): Bitmap? {
        val inputStream = contentResolver.openInputStream(uri)
        val options = BitmapFactory.Options().apply {
            inJustDecodeBounds = true
        }

        inputStream?.use { BitmapFactory.decodeStream(it, null, options) }

        options.inSampleSize = calculateInSampleSize(options, targetWidth, targetHeight)
        options.inJustDecodeBounds = false

        contentResolver.openInputStream(uri)?.use { inputStream2 ->
            return BitmapFactory.decodeStream(inputStream2, null, options)
        }

        throw IllegalStateException("Unable to open input stream.")
    }
    private fun calculateInSampleSize(options: BitmapFactory.Options, targetWidth: Int, targetHeight: Int): Int {
        val (width, height) = options.outWidth to options.outHeight
        var inSampleSize = 1

        if (height > targetHeight || width > targetWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2

            while (halfHeight / inSampleSize >= targetHeight && halfWidth / inSampleSize >= targetWidth) {
                inSampleSize *= 2
            }
        }

        return inSampleSize
    }

    @Throws(IOException::class)
    fun saveBitmapToTempFile(context: Context, bitmap: Bitmap, quality: Int, extension: String = "jpg"): File {
        val tempFile = File.createTempFile("temp_image", ".$extension", context.cacheDir).apply {
            deleteOnExit()
        }

        FileOutputStream(tempFile).use { outputStream ->
            bitmap.compress(Bitmap.CompressFormat.JPEG, quality, outputStream)
        }

        return tempFile
    }

    fun onCreateNewMessageClick(messageText: String, photoUri: Uri?) {
        val currentMoment: Instant = Clock.System.now()
        val message = Message(
            UUID.randomUUID().toString(),
            currentMoment,
            currentRoom.value.id,
            messageText,
            "author_me",
            null,
            photoUri
        )

        if (message.photoUri == null) {
            viewModelScope.launch(Dispatchers.Default) {
                repository.createMessageForRoom(message, currentRoom.value, null)
            }
        } else {
            GlobalScope.launch(Dispatchers.IO) {
                val timestamp = currentMoment.toLocalDateTime(TimeZone.UTC).toIso8601String()
                val contentResolver = appContext.contentResolver

                val downsampledBitmap = downsampleImageFromUri(contentResolver, message.photoUri)
                if (downsampledBitmap == null) {
                    println("Failed to downsample attachment")
                    repository.createMessageForRoom(message, currentRoom.value, null)
                } else {
                    // Save the downscaled image to a temporary file
                    val quality = 100
                    val tempFile: File?
                    try {
                        tempFile = saveBitmapToTempFile(appContext, downsampledBitmap, quality)
                        val collectionId = currentRoom.value.collectionID ?: DEFAULT_PUBLIC_ROOM_MESSAGES_COLLECTION_ID
                        val collection = DittoHandler.ditto.store.collection(collectionId)
                        val attachment = collection.newAttachment(
                            tempFile.inputStream(), mapOf(
                                metadataFilenameKey to message.userId + "_thumbnail_" + timestamp + ".jpg",
                                metadataFileformatKey to ".jpg",
                                metadataTimestampKey to timestamp,
                                metadataFilesizeKey to tempFile.length().toString()
                            )
                        )
                        repository.createMessageForRoom(message, currentRoom.value, attachment)
                    } catch (e: IOException) {
                        e.printStackTrace()
                        // Handle the error appropriately
                        println("Failed to save attachment to tempfile")
                        repository.createMessageForRoom(message, currentRoom.value, null)
                    }
                }
            }
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

    /**
     * Private Rooms
     */
    fun joinPrivateRoom(qrCode:String) {
        print(qrCode)
        viewModelScope.launch(Dispatchers.Default) {
            repository.joinPrivateRoom(qrCode)
        }

    }

}

data class EditProfileUiState(
    val currentFirstName: String = "",
    val currentLastName: String = ""
)
