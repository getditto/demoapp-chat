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

package live.dittolive.chat

import android.os.Bundle
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.rememberDrawerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.viewinterop.AndroidViewBinding
import androidx.core.os.bundleOf
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch
import live.ditto.transports.DittoSyncPermissions
import live.dittolive.chat.components.DittochatDrawer
import live.dittolive.chat.conversation.BackPressHandler
import live.dittolive.chat.conversation.LocalBackPressedDispatcher
import live.dittolive.chat.databinding.NavHostBinding
import live.dittolive.chat.viewmodel.MainViewModel


/**
 * Entry Point for Fragment based Navigation
 * Because we have to support Presence Viewer which is not compatible with Compose
 */
@AndroidEntryPoint
class NavActivity: AppCompatActivity() {

    private val viewModel: MainViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(
            ComposeView(this).apply {
                        setContent {
                            RequestPermission()

                            CompositionLocalProvider(
                                LocalBackPressedDispatcher provides this@NavActivity.onBackPressedDispatcher
                            ) {
                                val dittoSdkVersion : String by viewModel
                                    .dittoSdkVersion
                                    .collectAsStateWithLifecycle()

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
                                        println(it) // it is the selected room
                                        viewModel.setCurrentChatRoom(it)
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

    @Composable
    private fun RequestPermission() {
        val lifecycle = LocalLifecycleOwner.current.lifecycle

        val lifecycleObserver = remember {
            LifecycleEventObserver { _, event ->
                if (event == Lifecycle.Event.ON_START) {
                    val missing = DittoSyncPermissions(this).missingPermissions()
                    if (missing.isNotEmpty()) {
                        this.requestPermissions(missing, 0)
                    }
                }
            }
        }
        DisposableEffect(lifecycle, lifecycleObserver) {
            lifecycle.addObserver(lifecycleObserver)
            onDispose {
                lifecycle.removeObserver(lifecycleObserver)
            }
        }
    }
}