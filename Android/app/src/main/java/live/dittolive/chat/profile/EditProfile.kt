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

package live.dittolive.chat.profile

import androidx.compose.foundation.Image
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Divider
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.nestedscroll.NestedScrollConnection
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.rememberNestedScrollInteropConnection
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import live.dittolive.chat.FunctionalityNotAvailablePopup
import live.dittolive.chat.components.baselineHeight
import live.dittolive.chat.viewmodel.MainViewModel

@Composable
fun EditProfileScreen(
    userData: ProfileScreenState,
    nestedScrollInteropConnection: NestedScrollConnection = rememberNestedScrollInteropConnection(),
    viewModel: ProfileViewModel?,
    userViewModel: MainViewModel,
) {
    var functionalityNotAvailablePopupShown by remember { mutableStateOf(false) }
    if (functionalityNotAvailablePopupShown) {
        FunctionalityNotAvailablePopup { functionalityNotAvailablePopupShown = false }
    }

    val scrollState = rememberScrollState()

    var textState by rememberSaveable(stateSaver = TextFieldValue.Saver) {
        mutableStateOf(TextFieldValue())
    }

    BoxWithConstraints(
        modifier = Modifier
            .fillMaxSize()
            .nestedScroll(nestedScrollInteropConnection)
            .systemBarsPadding()
    ) {
        Surface {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(scrollState),
            ) {
                EditProfileHeader(
                    scrollState,
                    userData,
                    this@BoxWithConstraints.maxHeight
                )
                EditUserInfoFields(userData, this@BoxWithConstraints.maxHeight, userViewModel)
            }
        }

        val fabExtended by remember { derivedStateOf { scrollState.value == 0 } }
        ProfileFab(
            extended = fabExtended,
            userIsMe = userData.isMe(),
            isEditMode = true,
            modifier = Modifier
                .align(Alignment.BottomEnd)
                // Offsets the FAB to compensate for CoordinatorLayout collapsing behaviour
                .offset(y = ((-100).dp)),
            onFabClicked = {
                viewModel?.let {
                    //TODO : save profile data
                    userViewModel.updateUserInfo()

                    // switch back to non-edit mode
                    viewModel.changeEditMode()
                }
            }
        )
    }
}

@Composable
fun EditProfileHeader(
    scrollState: ScrollState,
    data: ProfileScreenState,
    containerHeight: Dp
) {
    val offset = (scrollState.value / 2)
    val offsetDp = with(LocalDensity.current) { offset.toDp() }

    data.photo?.let {
        Image(
            modifier = Modifier
                .heightIn(max = containerHeight / 2)
                .fillMaxWidth()
                // TODO: Update to use offset to avoid recomposition
                .padding(
                    start = 16.dp,
                    top = offsetDp,
                    end = 16.dp
                )
                .clip(CircleShape),
            painter = painterResource(id = it),
            contentScale = ContentScale.Crop,
            contentDescription = null
        )
    }
}

@Composable
fun EditUserInfoFields(userData: ProfileScreenState, containerHeight: Dp,  userViewModel: MainViewModel) {
    Column {
        Spacer(modifier = Modifier.height(8.dp))

        EditNameAndPosition(userData, userViewModel = userViewModel)

        // Add a spacer that always shows part (320.dp) of the fields list regardless of the device,
        // in order to always leave some content at the top.
        Spacer(Modifier.height((containerHeight - 320.dp).coerceAtLeast(0.dp)))
    }
}

@Composable
private fun EditNameAndPosition(
    userData: ProfileScreenState,
    userViewModel: MainViewModel
) {
    Column(modifier = Modifier.padding(horizontal = 16.dp)) {
        EditName(
            modifier = Modifier.baselineHeight(32.dp),
            userViewModel = userViewModel
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun EditName(modifier: Modifier = Modifier, userViewModel: MainViewModel) {
    val mainUiState by userViewModel.uiState.collectAsStateWithLifecycle()

    Text(text = "First Name")
    TextField(
        value = mainUiState.currentFirstName,
        singleLine = true,
        onValueChange = { userViewModel.updateFirstName(it) },

    )

    Text(text = "Last Name")
    TextField(
        value = mainUiState.currentLastName,
        singleLine = true,
        onValueChange = { userViewModel.updateLastName(it) },
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditProfileProperty(label: String, value: String, isLink: Boolean = false) {
    Column(modifier = Modifier.padding(start = 16.dp, end = 16.dp, bottom = 16.dp)) {
        val textState = remember { mutableStateOf(TextFieldValue()) }
        Divider()
        Text(
            text = label,
            modifier = Modifier.baselineHeight(24.dp),
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        val style = if (isLink) {
            MaterialTheme.typography.bodyLarge.copy(color = MaterialTheme.colorScheme.primary)
        } else {
            MaterialTheme.typography.bodyLarge
        }
        Text(
            text = value,
            modifier = Modifier.baselineHeight(24.dp),
            style = style
        )
        TextField(
            value =  textState.value,
            onValueChange = {textState.value = it},
            modifier = Modifier.baselineHeight(24.dp)
        )
    }
}

/**
 * Previews
 */
//@Preview(widthDp = 640, heightDp = 360)
//@Composable
//fun EditConvPreviewLandscapeMeDefault() {
//    DittochatTheme {
//        EditProfileScreen(meProfile, viewModel = null)
//    }
//}
//
//@Preview(widthDp = 360, heightDp = 480)
//@Preview(widthDp = 360, heightDp = 480)var id
//@Composable
//fun EditConvPreviewPortraitMeDefault() {
//    DittochatTheme {
//        EditProfileScreen(meProfile, viewModel = null, userViewModel = null)
//    }
//}
//
//@Preview(widthDp = 360, heightDp = 480)
//@Composable
//fun EditConvPreviewPortraitOtherDefault() {
//    DittochatTheme {
//        EditProfileScreen(colleagueProfile, viewModel = null)
//    }
//}