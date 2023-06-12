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




private val initialUiMessages = listOf(
    MessageUiModel(
        Message(
            UUID.randomUUID().toString(),
            Clock.System.now(),
            "public",
            "Check it out!",
            "me",
        ),
        user = User("me", "Fuad", "Kamal")
    ),
    MessageUiModel(
        Message(
            UUID.randomUUID().toString(),
            Clock.System.now(),
            "public",
            "Thank you!",
            "me",
            null,
        ),
        user = User("me", "Fuad", "Kamal")
    ),
    MessageUiModel(
        Message(
            UUID.randomUUID().toString(),
            Clock.System.now(),
            "public",
            "You can use all the same stuff",
            "Eric Turner",
        ),
        user = User("Eric Turner", "Eric", "Turner")
    ),
    MessageUiModel(
        Message(
            UUID.randomUUID().toString(),
            Clock.System.now(),
            "public",
            "@flexronin Take a look at the `Flow.collectAsStateWithLifecycle()` APIs",
            "Eric Turner",
        ),
        user = User("Eric Turner", "Eric", "Turner")
    ),
)

private val initialMessages = listOf(
    Message(
        UUID.randomUUID().toString(),
        Clock.System.now(),
        "public",
        "Check it out!",
        "me",
    ),
    Message(
        UUID.randomUUID().toString(),
        Clock.System.now(),
        "public",
        "Thank you!",
        "me",
        null,
    ),
    Message(
        UUID.randomUUID().toString(),
        Clock.System.now(),
        "public",
        "You can use all the same stuff",
        "Eric Turner",
    ),
    Message(
        UUID.randomUUID().toString(),
        Clock.System.now(),
        "public",
        "@flexronin Take a look at the `Flow.collectAsStateWithLifecycle()` APIs",
        "Eric Turner",
    ),
    Message(
        UUID.randomUUID().toString(),
        Clock.System.now(),
        "public",
        "Compose newbie as well, have you looked at the JetNews sample? Most blog posts end up " +
            "out of date pretty fast but this sample is always up to date and deals with async " +
            "data loading (it's faked but the same idea applies) \uD83D\uDC49" +
            "https://github.com/android/compose-samples/tree/master/JetNews",
        "John Glenn"
    ),
    Message(
        UUID.randomUUID().toString(),
        Clock.System.now(),
        "public",
        "me",
        "Compose newbie: I’ve scourged the internet for tutorials about async data loading " +
            "but haven’t found any good ones. What’s the recommended way to load async " +
            "data and emit composable widgets?",

    )
)

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
