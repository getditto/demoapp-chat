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

package live.dittolive.chat.components

import androidx.annotation.DrawableRes
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.windowInsetsTopHeight
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Message
import androidx.compose.material.icons.outlined.QrCodeScanner
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment.Companion.CenterStart
import androidx.compose.ui.Alignment.Companion.CenterVertically
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.codescanner.GmsBarcodeScannerOptions
import com.google.mlkit.vision.codescanner.GmsBarcodeScanning
import live.dittolive.chat.R
import live.dittolive.chat.data.meProfile
import live.dittolive.chat.data.model.ChatRoom
import live.dittolive.chat.viewmodel.MainViewModel


/**
 * @param onProfileClicked function defining the action when the profile is clicked. takes userId:String and isMe:Boolean which is to say
 * whether the profile clicked belongs to the user of the device
 */
@Composable
fun DittochatDrawerContent(
    onProfileClicked: (String) -> Unit,
    onChatClicked: (ChatRoom) -> Unit,
    onPresenceViewerClicked: (String) -> Unit,
    sdkVersion : String,
    viewModel: MainViewModel
) {
    val versionName = live.dittolive.chat.BuildConfig.VERSION_NAME
    val mainUiState by viewModel.uiState.collectAsStateWithLifecycle()
    val userId by viewModel.currentUserId.collectAsStateWithLifecycle()

    val fullName = ("${mainUiState.currentFirstName + " " + mainUiState.currentLastName} (you)")
    val meUserId = userId

    /**
     * QR Code Scanning Functionality
     */
    val options = GmsBarcodeScannerOptions.Builder()
        .setBarcodeFormats(
            Barcode.FORMAT_QR_CODE)
        .build()

    val scanner = GmsBarcodeScanning.getClient(LocalContext.current, options)



    // Use windowInsetsTopHeight() to add a spacer which pushes the drawer content
    // below the status bar (y-axis)
    Column(modifier = Modifier
        .fillMaxSize()
        .background(MaterialTheme.colorScheme.background)) {
        Spacer(Modifier.windowInsetsTopHeight(WindowInsets.statusBars))
        DrawerHeader()
        DividerItem()
        Row(modifier = Modifier.padding(16.dp), verticalAlignment = CenterVertically) {
            DrawerItemHeader(stringResource(R.string.chats))
            Icon(
                imageVector = Icons.Outlined.QrCodeScanner,
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier
                    .clickable(onClick = {
                        scanner
                            .startScan()
                            .addOnSuccessListener { barcode ->
                                // Task completed successfully
                                val rawValue: String? = barcode.rawValue
                                rawValue?.let {
                                    viewModel.joinPrivateRoom(it)
                                }
                            }
                            .addOnCanceledListener {
                                // Task canceled
                            }
                            .addOnFailureListener { e ->
                                // Task failed with an exception
                            }
                    })
                    .padding(horizontal = 12.dp, vertical = 16.dp)
                    .height(24.dp),
                contentDescription = stringResource(id = R.string.info)
            )
            Icon(
                imageVector = Icons.Outlined.Message,
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier
                    .clickable(onClick = { /* TODO */ })
                    .padding(horizontal = 12.dp, vertical = 16.dp)
                    .height(24.dp),
                contentDescription = stringResource(id = R.string.info)
            )
        }
        
        DividerItem()
        DrawerItemHeader(stringResource(R.string.public_rooms))
        //list of public rooms
        PublicRoomsList(viewModel, onChatClicked)

        DividerItem()
        DrawerItemHeader(stringResource(R.string.private_rooms))
        // private rooms 🚧
        PrivateRoomsList(viewModel = viewModel, onChatClicked = onChatClicked)


        DividerItem(modifier = Modifier.padding(horizontal = 28.dp))
        DrawerItemHeader(stringResource(R.string.recent_profiles))
        ProfileItem(fullName, meProfile.photo) {
            onProfileClicked(meUserId)
        }
        DividerItem(modifier = Modifier.padding(horizontal = 28.dp))
        TextButton(onClick = {
            onPresenceViewerClicked("Presence Viewer")
        }) {
            Text("Presence Viewer")
        }
        DividerItem(modifier = Modifier.padding(horizontal = 28.dp))
        DrawerItemHeader(sdkVersion)
        DrawerItemHeader(text = "Ditto Chat v$versionName")
    }
}

@Composable
fun PublicRoomsList(
    viewModel: MainViewModel,
    onChatClicked: (ChatRoom) -> Unit,
) {
    // TODO : Implement
    val publicChatRooms : List<ChatRoom> by viewModel
        .allPublicRoomsFLow
        .collectAsStateWithLifecycle(
            initialValue = emptyList()
        )

    LazyColumn {
        items(publicChatRooms) { publicRoom ->
            ChatItem(publicRoom.name, true) { onChatClicked(publicRoom) }
        }
    }
}


@Composable
fun PrivateRoomsList(
    viewModel: MainViewModel,
    onChatClicked: (ChatRoom) -> Unit,
) {

    val privateChatRooms : List<ChatRoom> by viewModel
        .allPrivateRoomsFlow
        .collectAsStateWithLifecycle(
            initialValue = emptyList()
        )

    LazyColumn {
        items(privateChatRooms) { publicRoom ->
            ChatItem(publicRoom.name, true) { onChatClicked(publicRoom) }
        }
    }
}


@Composable
private fun DrawerHeader() {
    Row(modifier = Modifier.padding(16.dp), verticalAlignment = CenterVertically) {
        JetchatIcon(
            contentDescription = null,
            modifier = Modifier.size(24.dp)
        )
        Image(
            painter = painterResource(id = R.drawable.dittochat_logo),
            contentDescription = null,
            modifier = Modifier.padding(start = 8.dp)
        )
    }
}
@Composable
private fun DrawerItemHeader(text: String) {
    Box(
        modifier = Modifier
            .heightIn(min = 52.dp)
            .padding(horizontal = 28.dp),
        contentAlignment = CenterStart
    ) {
        Text(
            text,
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun ChatItem(text: String, selected: Boolean, onChatClicked: () -> Unit) {
    val background = if (selected) {
        Modifier.background(MaterialTheme.colorScheme.primaryContainer)
    } else {
        Modifier
    }
    Row(
        modifier = Modifier
            .height(56.dp)
            .fillMaxWidth()
            .padding(horizontal = 12.dp)
            .clip(CircleShape)
            .then(background)
            .clickable(onClick = onChatClicked),
        verticalAlignment = CenterVertically
    ) {
        val iconTint = if (selected) {
            MaterialTheme.colorScheme.primary
        } else {
            MaterialTheme.colorScheme.onSurfaceVariant
        }
        Icon(
            painter = painterResource(id = R.drawable.ic_dittochat),
            tint = iconTint,
            modifier = Modifier.padding(start = 16.dp, top = 16.dp, bottom = 16.dp),
            contentDescription = null
        )
        Text(
            text,
            style = MaterialTheme.typography.bodyMedium,
            color = if (selected) {
                MaterialTheme.colorScheme.primary
            } else {
                MaterialTheme.colorScheme.onSurface
            },
            modifier = Modifier.padding(start = 12.dp)
        )
    }
}

@Composable
private fun ProfileItem(text: String, @DrawableRes profilePic: Int?, onProfileClicked: () -> Unit) {
    Row(
        modifier = Modifier
            .height(56.dp)
            .fillMaxWidth()
            .padding(horizontal = 12.dp)
            .clip(CircleShape)
            .clickable(onClick = onProfileClicked),
        verticalAlignment = CenterVertically
    ) {
        val paddingSizeModifier = Modifier
            .padding(start = 16.dp, top = 16.dp, bottom = 16.dp)
            .size(24.dp)
        if (profilePic != null) {
            Image(
                painter = painterResource(id = profilePic),
                modifier = paddingSizeModifier.then(Modifier.clip(CircleShape)),
                contentScale = ContentScale.Crop,
                contentDescription = null
            )
        } else {
            Spacer(modifier = paddingSizeModifier)
        }
        Text(
            text,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurface,
            modifier = Modifier.padding(start = 12.dp)
        )
    }
}

@Composable
fun DividerItem(modifier: Modifier = Modifier) {
    Divider(
        modifier = modifier,
        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.12f)
    )
}

//@Composable
//@Preview
//fun DrawerPreview() {
//    DittochatTheme {
//        Surface {
//            Column {
//                DittochatDrawerContent({}, {},{}, "1.90", viewModel = null)
//            }
//        }
//    }
//}
//@Composable
//@Preview
//fun DrawerPreviewDark() {
//    DittochatTheme(isDarkTheme = true) {
//        Surface {
//            Column {
//                DittochatDrawerContent({}, {},{}, "1.90", viewModel = null)
//            }
//        }
//    }
//}

