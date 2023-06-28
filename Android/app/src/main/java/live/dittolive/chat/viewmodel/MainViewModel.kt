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
import android.util.Log
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
import live.dittolive.chat.data.metadataFileformatKey
import live.dittolive.chat.data.metadataFilenameKey
import live.dittolive.chat.data.metadataFilesizeKey
import live.dittolive.chat.data.metadataTimestampKey
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
import java.io.FileOutputStream
import java.io.IOException
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

        messages.map { message ->
            MessageUiModel.invoke(
                message = message,
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
    private fun downsampleImageFromUri(contentResolver: ContentResolver, uri: Uri, targetWidth: Int, targetHeight: Int): Bitmap? {
        val inputStream = contentResolver.openInputStream(uri)
        val options = BitmapFactory.Options().apply {
            inJustDecodeBounds = true
        }

        inputStream?.use { BitmapFactory.decodeStream(it, null, options) }

        options.inSampleSize = calculateInSampleSize(options, targetWidth, targetHeight)
        options.inJustDecodeBounds = false

        contentResolver.openInputStream(uri)?.use { inputStream2 ->
            if (inputStream2 != null) {
                return BitmapFactory.decodeStream(inputStream2, null, options)
            }
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
    private fun uriToInputStream(uri: Uri): InputStream? {
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
    fun onCreateNewMessageClick(message: Message) {
        viewModelScope.launch(Dispatchers.Default) {
            if (message.photoUri == null) {
                repository.createMessage(message, null)
            } else {
                // get context
                GlobalScope.launch(Dispatchers.IO) {
                        val currentMoment: Instant = Clock.System.now()
                        val timestamp = currentMoment.toLocalDateTime(TimeZone.UTC).toIso8601String()
                        val contentResolver = context.contentResolver
                        val targetWidth = 282 // Replace it with the desired width
                        val targetHeight = 376 // Replace it with the desired height

                        val downsampledBitmap = downsampleImageFromUri(contentResolver, message.photoUri, targetWidth, targetHeight)
                        if (downsampledBitmap == null) {
                            println("Failed to downsample attachment")
                            repository.createMessage(message, null)
                        } else {
                            // Save the downscaled image to a temporary file
                            val quality = 100
                            var tempFile: File? = null
                            try {
                                tempFile = saveBitmapToTempFile(context, downsampledBitmap, quality)
                                val collection =
                                    DittoHandler.ditto.store.collection(DEFAULT_PUBLIC_ROOM)
                                val attachment = collection.newAttachment(
                                    tempFile.inputStream(), mapOf(
                                        metadataFilenameKey to message.userId + "_thumbnail_" + timestamp + ".jpg",
                                        metadataFileformatKey to ".jpg",
                                        metadataTimestampKey to timestamp,
                                        metadataFilesizeKey to tempFile.length().toString()
                                    )
                                )
                                repository.createMessage(message, attachment)
                            } catch (e: IOException) {
                                e.printStackTrace()
                                // Handle the error appropriately
                                println("Failed to save attachment to tempfile")
                                repository.createMessage(message, null)
                            }
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
