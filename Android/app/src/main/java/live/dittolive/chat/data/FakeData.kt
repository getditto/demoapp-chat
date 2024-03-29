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

package live.dittolive.chat.data

import kotlinx.datetime.Clock
import live.dittolive.chat.R
import live.dittolive.chat.conversation.Message
import live.dittolive.chat.data.model.MessageUiModel
import live.dittolive.chat.data.model.User
import live.dittolive.chat.profile.ProfileScreenState
import java.util.UUID


//val exampleUiState = ConversationUiState(
//    initialMessages = initialUiMessages,
//    channelName = "#public",
//    channelMembers = 42,
//    viewModel = null
//)

/**
 * Example colleague profile
 */
val colleagueProfile = ProfileScreenState(
    userId = "12345",
    photo = R.drawable.someone_else,
    name = "Eric Turner",
    status = "Away",
    displayName = "eric",
    position = "Senior iOS Dev at Ditto",
    twitter = "twitter.com/EricTurner",
    timeZone = "12:25 AM local time (Eastern Daylight Time)",
    commonChannels = "2"
)

val colleagueUser = User(
    id = "12345",
    firstName = "Eric",
    lastName = "Turner"
)

/**
 * Example "me" profile.
 */
val meProfile = ProfileScreenState(
    userId = "me",
    photo = R.drawable.profile_photo_android_developer,
    name = "Fuad Kamal",
    status = "Online",
    displayName = "flexronin",
    position = "Senior Customer Engineer at Ditto\nAuthor of Android App Distribution",
    twitter = "twitter.com/flexronin",
    timeZone = "In your timezone",
    commonChannels = null
)
