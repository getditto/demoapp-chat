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

package live.ditto.chat

import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.rememberDrawerState
import androidx.compose.runtime.*
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.viewinterop.AndroidViewBinding
import androidx.core.os.bundleOf
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch
import live.ditto.chat.components.DittochatDrawer
import live.ditto.chat.conversation.BackPressHandler
import live.ditto.chat.conversation.LocalBackPressedDispatcher
import live.ditto.chat.databinding.NavHostBinding
import live.ditto.chat.viewmodel.MainViewModel


/**
 * Entry Point for Fragment based Navigation
 * Because we have to support Presence Viewer which is not compatible with Compose
 */
@AndroidEntryPoint
class NavActivity: AppCompatActivity() {

    private val viewModel: MainViewModel by viewModels()

    @OptIn(ExperimentalMaterial3Api::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(
            ComposeView(this).apply {
                        setContent {
                            CompositionLocalProvider(
                                LocalBackPressedDispatcher provides this@NavActivity.onBackPressedDispatcher
                            ) {
                                val dittoSdkVersion : String by viewModel
                                    .dittoSdkVersion
                                    .collectAsState(initial = " ")

                                val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
                                val drawerOpen by viewModel.drawerShouldBeOpened
                                    .collectAsStateWithLifecycle()

                                if (drawerOpen) {
                                    // Open drawer and reset state in VM.
                                    LaunchedEffect(Unit) {
                                        // wrap in try-finally to handle interruption whiles opening drawer
                                        try {
                                            drawerState.open()
                                        } finally {
                                            viewModel.resetOpenDrawerAction()
                                        }
                                    }
                                }

                                // Intercepts back navigation when the drawer is open
                                val scope = rememberCoroutineScope()
                                if (drawerState.isOpen) {
                                    BackPressHandler {
                                        scope.launch {
                                            drawerState.close()
                                        }
                                    }
                                }

                                DittochatDrawer(
                                    drawerState = drawerState,
                                    onChatClicked = {
                                        findNavController().popBackStack(R.id.nav_home, false)
                                        scope.launch {
                                            drawerState.close()
                                        }
                                    },
                                    onProfileClicked = {
                                        val bundle = bundleOf("userId" to it)
                                        findNavController().navigate(R.id.nav_profile, bundle)
                                        scope.launch {
                                            drawerState.close()
                                        }
                                    },
                                    onPresenceViewerClicked = {
                                        findNavController().navigate(R.id.presenceViewerActivity)
                                        scope.launch {
                                            drawerState.close()
                                        }
                                    },
                                    dittoSdkVersion = "Ditto SDK ver "+ dittoSdkVersion,
                                    viewModel = viewModel
                                ) {
                                    AndroidViewBinding(NavHostBinding::inflate)
                                }

                            }

                        }
            }
        )
    }

    /**
     * See https://issuetracker.google.com/142847973
     */
    private fun findNavController(): NavController {
        val navHostFragment =
            supportFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        return navHostFragment.navController
    }

}