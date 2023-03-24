/*
 * Copyright (c) 2023 DittoLive.
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

package live.ditto.chat.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.Button
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.map
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.MultiplePermissionsState
import com.google.accompanist.permissions.PermissionState
import live.ditto.chat.viewmodel.MainViewModel
import live.ditto.chat.conversation.ConversationContent
import live.ditto.chat.conversation.ConversationUiState
import live.ditto.chat.conversation.Message
import live.ditto.chat.data.model.MessageUiModel
import live.ditto.chat.data.model.User
import live.ditto.chat.presenceviewer.PresenceViewerDisplay
import live.ditto.chat.theme.DittochatTheme
import live.ditto.dittopresenceviewer.PresenceViewModel


/**
 * Permissions Request Handling
 */
@OptIn(ExperimentalPermissionsApi::class)
@Composable
fun PermissionsAndChatScreen(viewModel: MainViewModel, multiplePermissionsState: MultiplePermissionsState, presenceViewModel: PresenceViewModel) {
    val users : List<User> by viewModel
        .users
        .observeAsState(listOf())

    val messagesWithUsers : List<MessageUiModel> by viewModel
        .messagesWithUsersFlow
        .collectAsState(initial = emptyList())


    val currentUiState = ConversationUiState(
        initialMessages = messagesWithUsers.asReversed(), // We reverse the list, b/c iOS list is reverse order of ours
        channelName = "#public", // TODO : update with actual room name - "public" is the default public room
        channelMembers = users.count() , // TODO : update with actual count from room members
        viewModel = viewModel
    )

    if (multiplePermissionsState.allPermissionsGranted) {
        //Temp - testing Presence viewer
//        PresenceViewerDisplay(modifier = Modifier.fillMaxSize(), viewModel = viewModel, presenceViewModel)
        // If all permissions are granted, then show screen with the feature enabled
//        Text("BLE permissions Granted! Thank you!")
        // TODO : replace with main content for this screen
        DittochatTheme {
            ConversationContent(
                uiState = currentUiState,
                navigateToProfile = { user ->
                    // Click callback
                    // TODO : Implement
//                    val bundle = bundleOf("userId" to user)
//                    findNavController().navigate(
//                        R.id.nav_profile,
//                        bundle
//                    )
                },
                onNavIconPressed = {
//                    activityViewModel.openDrawer()
                },
                // Add padding so that we are inset from any navigation bars
                modifier = Modifier.windowInsetsPadding(
                    WindowInsets
                        .navigationBars
                        .only(WindowInsetsSides.Horizontal + WindowInsetsSides.Top)
                )
            )

        }

    } else {
        Column {
            Text(
                getTextToShowGivenPermissions(
                    multiplePermissionsState.revokedPermissions,
                    multiplePermissionsState.shouldShowRationale
                )
            )
            Spacer(modifier = Modifier.height(8.dp))
            Button(onClick = { multiplePermissionsState.launchMultiplePermissionRequest() }) {
                Text("Request permissions")
            }
        }
    }
}

@OptIn(ExperimentalPermissionsApi::class)
fun getTextToShowGivenPermissions(
    permissions: List<PermissionState>,
    shouldShowRationale: Boolean
): String {
    val revokedPermissionsSize = permissions.size
    if (revokedPermissionsSize == 0) return ""

    val textToShow = StringBuilder().apply {
        append("The ")
    }

    for (i in permissions.indices) {
        textToShow.append(permissions[i].permission)
        when {
            revokedPermissionsSize > 1 && i == revokedPermissionsSize - 2 -> {
                textToShow.append(", and ")
            }
            i == revokedPermissionsSize - 1 -> {
                textToShow.append(" ")
            }
            else -> {
                textToShow.append(", ")
            }
        }
    }
    textToShow.append(if (revokedPermissionsSize == 1) "permission is" else "permissions are")
    textToShow.append(
        if (shouldShowRationale) {
            " important. Please grant all of them for the app to function properly."
        } else {
            " denied. The app cannot function without them."
        }
    )
    return textToShow.toString()
}

fun profileCLickAction() {
    // TODO : Implement
}

fun chatClickAction() {
    // TODO : Implement
}