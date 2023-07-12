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

package live.dittolive.chat.conversation

import android.net.Uri
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.toMutableStateList
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import live.ditto.DittoAttachmentToken
import live.ditto.DittoDocument
import live.dittolive.chat.R
import live.dittolive.chat.data.createdOnKey
import live.dittolive.chat.data.dbIdKey
import live.dittolive.chat.data.model.MessageUiModel
import live.dittolive.chat.data.model.toInstant
import live.dittolive.chat.data.roomIdKey
import live.dittolive.chat.data.textKey
import live.dittolive.chat.data.thumbnailKey
import live.dittolive.chat.data.userIdKey
import live.dittolive.chat.viewmodel.MainViewModel
import java.util.UUID

class ConversationUiState(
    val channelName: String,
    initialMessages: List<MessageUiModel>,
    val viewModel: MainViewModel
) {
    private val _messages: MutableList<MessageUiModel> = initialMessages.toMutableStateList()

    val messages: List<MessageUiModel> = _messages
    //author ID is set to the user ID - it's used to tell if the message is sent from this user (self) when rendering the UI
    val authorId: MutableStateFlow<String> = viewModel.currentUserId

    fun addMessage(msg: MessageUiModel) {
        viewModel.onCreateNewMessageClick(msg.message)
    }
}

/**
 * TODO : move to separate data class
 */
@Immutable
data class Message(
    val _id: String = UUID.randomUUID().toString(),
    val createdOn: Instant? = Clock.System.now(),
    val roomId: String = "public", // "public" is the roomID for the default public chat room
    val text: String = "test",
    val userId: String = UUID.randomUUID().toString(),
    val attachmentToken: DittoAttachmentToken?,
    // local metadata, not part of the ditto document
    val photoUri: Uri? = null,
    val authorImage: Int = if (userId == "me") R.drawable.profile_photo_android_developer else R.drawable.someone_else
) {
    constructor(document: DittoDocument) :this(
        document[dbIdKey].stringValue,
        document[createdOnKey].stringValue.toInstant(),
        document[roomIdKey].stringValue,
        document[textKey].stringValue,
        document[userIdKey].stringValue,
        document[thumbnailKey].attachmentToken
    )
}
