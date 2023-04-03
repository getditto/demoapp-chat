/*
 * Copyright (c) 2021-2023 DittoLive.
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the “Software”), to deal
 * In the Software without restriction, including without limitation the rights
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
package live.ditto.chat.viewmodel

import androidx.lifecycle.*
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import live.ditto.chat.conversation.Message
import live.ditto.chat.data.model.MessageUiModel
import live.ditto.chat.data.model.User
import live.ditto.chat.data.repository.Repository
import live.ditto.chat.data.repository.UserPreferencesRepository
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

    /**
     * Some setup required...
     */
    init {
        viewModelScope.launch {
            currentUserId.value =  userPreferencesRepository.fetchInitialPreferences().currentUserId
        }

        // temporary user initialziation - replace once UI functionality exists to edit the user name
        val firstName = "My"
        val lastName = android.os.Build.MODEL
        viewModelScope.launch {
            repository.saveCurrentUser(firstName, lastName) //TODO : set by user on app launch <----
        }
        _dittoSdkVersion.value = repository.getDittoSdkVersion()
    }

    fun getUserById(id: String): User? {
        val user : User? = users.value?.find { user: User -> user.id == id }
        return user
    }

    fun getCurrentUser() : User? {
        return getUserById(currentUserId.value)
    }


    fun onCreateNewMessageClick(message: Message) {
        viewModelScope.launch(Dispatchers.Default) {
            repository.createMessage(message)
        }
    }

    fun onProfileClick() {
        // TODO : open profile screen
    }

    fun openDrawer() {
        _drawerShouldBeOpened.value = true
    }

    fun resetOpenDrawerAction() {
        _drawerShouldBeOpened.value = false
    }

}
