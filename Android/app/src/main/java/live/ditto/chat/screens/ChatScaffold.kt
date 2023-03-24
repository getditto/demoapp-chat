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

import android.Manifest
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Chat
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.core.os.bundleOf
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.rememberMultiplePermissionsState
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import live.ditto.chat.components.DittochatDrawerContent
import live.ditto.chat.components.JetchatIcon
import live.ditto.chat.viewmodel.MainViewModel
import live.ditto.dittopresenceviewer.PresenceViewModel
import live.ditto.chat.R

@OptIn(ExperimentalPermissionsApi::class, ExperimentalMaterial3Api::class)
@Composable
fun ChatScaffold(viewModel: MainViewModel, presenceViewModel: PresenceViewModel) {
    val scaffoldState: ScaffoldState = rememberScaffoldState()
    val scope: CoroutineScope = rememberCoroutineScope()
    val dittoSdkVersion : String by viewModel
        .dittoSdkVersion
        .collectAsState(initial = " ")

    val drawerState =
        androidx.compose.material3.rememberDrawerState(initialValue = DrawerValue.Closed)
    Scaffold(
        scaffoldState = scaffoldState,
        modifier = Modifier.fillMaxSize(),
        contentColor = colorResource(id = R.color.colorPrimary),
        content = { padding ->
            Modifier.padding(16.dp)
//                  MyColumn()
            val multiplePermissionsState = rememberMultiplePermissionsState(
                listOf(
//                    android.Manifest.permission.ACCESS_FINE_LOCATION, // TODO : Request for API <= 32...
                    // TODO : add API level logic
                    Manifest.permission.NEARBY_WIFI_DEVICES,
                    Manifest.permission.BLUETOOTH_SCAN,
                    Manifest.permission.BLUETOOTH_ADVERTISE,
                    Manifest.permission.BLUETOOTH_CONNECT,
                )
            )
            PermissionsAndChatScreen(viewModel, multiplePermissionsState, presenceViewModel)
        },
        topBar = { MyTopAppBar(scaffoldState = scaffoldState, scope = scope) },
//        bottomBar = { MyBottomAppBar() },
//        floatingActionButtonPosition = FabPosition.End,
//        floatingActionButton = { MyFloatingActionButton() },
        drawerContent = {
//            Text(stringResource(R.string.menu_title), modifier = Modifier.padding(16.dp))
//            Divider()
//            // Drawer items
//            MenuItemsScreen()

            DittochatDrawerContent(
                onProfileClicked = {
//                    findNavController().popBackStack(R.id.nav_home, false)
                    scope.launch {
                        drawerState.close()
                    }
                },
                onChatClicked = {
                    val bundle = bundleOf("userId" to it)
//                    findNavController().navigate(R.id.nav_profile, bundle)
                    scope.launch {
                        drawerState.close()
                    }
                },
                onPresenceViewerClicked = {},
                sdkVersion = "Ditto SDK: "+dittoSdkVersion
            )
        }
    )
}

@Composable
fun MyTopAppBar(scaffoldState: ScaffoldState, scope: CoroutineScope) {
    val drawerState = scaffoldState.drawerState

    TopAppBar(
        navigationIcon = {
            IconButton(
                content = {
                    JetchatIcon(contentDescription = stringResource(R.string.menu))
//                    Icon(
//                        Icons.Default.Menu,
//                        tint = Color.White,
//                        contentDescription = stringResource(R.string.menu)
//                    )
                },
                onClick = {
                    scope.launch { if (drawerState.isClosed) drawerState.open() else drawerState.close() }
                }
            )
        },
        title = { Text(text = stringResource(id = R.string.app_title), color = Color.White) },
        backgroundColor = colorResource(id = R.color.colorPrimary)
    )
}

// public vs private chat room buttons
@Preview
@Composable
fun PublicChatButton() {
    Button(
        onClick = {},
        colors = ButtonDefaults.buttonColors(backgroundColor = colorResource(id = R.color.colorPrimary)),
        border = BorderStroke(
            1.dp,
            color = colorResource(id = R.color.colorPrimaryDark)
        )
    ) {
        Text(
            text = stringResource(id = R.string.public_room_button_text),
            color = Color.White
        )
    }
}

@Preview
@Composable
fun PrivateChatButton() {
    Button(
        onClick = {},
        colors = ButtonDefaults.buttonColors(backgroundColor = colorResource(id = R.color.colorPrimary)),
        border = BorderStroke(
            1.dp,
            color = colorResource(id = R.color.colorPrimaryDark)
        )
    ) {
        Text(
            text = stringResource(id = R.string.private_room_button_text),
            color = Color.White
        )
    }
}

@Preview
@Composable
fun AllChatsButton() {
    Button(
        onClick = {},
        colors = ButtonDefaults.buttonColors(backgroundColor = colorResource(id = R.color.colorPrimary)),
        border = BorderStroke(
            1.dp,
            color = colorResource(id = R.color.colorPrimaryDark)
        )
    ) {
        Text(
            text = stringResource(id = R.string.all_rooms_button_text),
            color = Color.White
        )
    }
}

@Composable
fun MyBottomAppBar() {
    BottomAppBar(
        content = {
            AllChatsButton()
            PublicChatButton()
            PrivateChatButton()
        },
        backgroundColor = colorResource(id = R.color.colorPrimary)
    )
}


@Composable
fun MyFloatingActionButton() {
    FloatingActionButton(
        onClick = {},
        backgroundColor = colorResource(id = R.color.colorPrimary),
        contentColor = Color.White,
        content = {
            Icon(Icons.Filled.Chat, contentDescription = "New Chat")
        }
    )
}

//private fun checkLocationPermission() {
//    // TODO : Composable permissions request using Accompanist
//    val missing = DittoSyncPermissions(this).missingPermissions()
//    if (missing.isNotEmpty()) {
//        this.requestPermissions(missing, 0)
//    }
//}
