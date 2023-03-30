/*
 * Copyright 2020 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package live.ditto.chat.conversation

import android.Manifest
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import androidx.compose.foundation.layout.*
import androidx.compose.material.Button
import androidx.compose.material.Text
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.livedata.observeAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.unit.dp
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.findNavController
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.rememberMultiplePermissionsState
import live.ditto.chat.R
import live.ditto.chat.data.model.MessageUiModel
import live.ditto.chat.data.model.User
import live.ditto.chat.screens.getTextToShowGivenPermissions
import live.ditto.chat.theme.DittochatTheme
import live.ditto.chat.utilities.Permissions
import live.ditto.chat.viewmodel.MainViewModel

class ConversationFragment : Fragment() {

    private val activityViewModel: MainViewModel by activityViewModels()

    @OptIn(ExperimentalPermissionsApi::class)
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View = ComposeView(inflater.context).apply {
        layoutParams = LayoutParams(MATCH_PARENT, MATCH_PARENT)

        setContent {
            CompositionLocalProvider(
                LocalBackPressedDispatcher provides requireActivity().onBackPressedDispatcher
            ) {
                val users : List<User> by activityViewModel
                    .users
                    .observeAsState(listOf())

                val messagesWithUsers : List<MessageUiModel> by activityViewModel
                    .messagesWithUsersFlow
                    .collectAsState(initial = emptyList())

                val currentUiState = ConversationUiState(
                    initialMessages = messagesWithUsers.asReversed(), // We reverse the list, b/c iOS list is reverse order of ours
                    channelName = "#public", // TODO : update with actual room name - "public" is the default public room
                    channelMembers = users.count() , // TODO : update with actual count from room members
                    viewModel = activityViewModel
                )

                val multiplePermissionsState = rememberMultiplePermissionsState(Permissions().requiredPermissions())

                if (multiplePermissionsState.allPermissionsGranted) {
                    DittochatTheme {
                        ConversationContent(
                            uiState = currentUiState,
                            navigateToProfile = { user ->
                                // Click callback
                                val bundle = bundleOf("userId" to user)
                                findNavController().navigate(
                                    R.id.nav_profile,
                                    bundle
                                )
                            },
                            onNavIconPressed = {
                                activityViewModel.openDrawer()
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
        }
    }
}
