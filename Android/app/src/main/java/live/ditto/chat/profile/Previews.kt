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

package live.ditto.chat.profile

import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import live.ditto.chat.data.colleagueProfile
import live.ditto.chat.data.meProfile
import live.ditto.chat.theme.DittochatTheme

@Preview(widthDp = 340, name = "340 width - Me")
@Composable
fun ProfilePreview340() {
    DittochatTheme {
        ProfileScreen(meProfile, viewModel = null, userViewModel = null, isMe = true)
    }
}

@Preview(widthDp = 480, name = "480 width - Me")
@Composable
fun ProfilePreview480Me() {
    DittochatTheme {
        ProfileScreen(meProfile, viewModel = null, userViewModel = null, isMe = true)
    }
}

@Preview(widthDp = 480, name = "480 width - Other")
@Composable
fun ProfilePreview480Other() {
    DittochatTheme {
        ProfileScreen(colleagueProfile, viewModel = null, userViewModel = null, isMe = false)
    }
}
@Preview(widthDp = 340, name = "340 width - Me - Dark")
@Composable
fun ProfilePreview340MeDark() {
    DittochatTheme(isDarkTheme = true) {
        ProfileScreen(meProfile, viewModel = null, userViewModel = null, isMe = true)
    }
}

@Preview(widthDp = 480, name = "480 width - Me - Dark")
@Composable
fun ProfilePreview480MeDark() {
    DittochatTheme(isDarkTheme = true) {
        ProfileScreen(meProfile, viewModel = null, userViewModel = null, isMe = true)
    }
}

@Preview(widthDp = 480, name = "480 width - Other - Dark")
@Composable
fun ProfilePreview480OtherDark() {
    DittochatTheme(isDarkTheme = true) {
        ProfileScreen(colleagueProfile, viewModel = null, userViewModel = null, isMe = false)
    }
}
