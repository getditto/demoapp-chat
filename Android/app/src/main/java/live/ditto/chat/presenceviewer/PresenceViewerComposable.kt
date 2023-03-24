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

package live.ditto.chat.presenceviewer

import android.app.Application
import android.util.Log
import android.webkit.ConsoleMessage
import android.webkit.WebChromeClient
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.viewinterop.AndroidViewBinding
import androidx.lifecycle.findViewTreeLifecycleOwner
import live.ditto.chat.DittoHandler.Companion.ditto
import live.ditto.chat.R
import live.ditto.chat.databinding.ActivityPresenceViewerBinding
import live.ditto.chat.viewmodel.MainViewModel
import live.ditto.dittopresenceviewer.PresenceViewModel
import live.ditto.dittopresenceviewer.PresenceViewerFragment
import live.ditto.dittopresenceviewer.databinding.FragmentPresenceViewerBinding

//class PresenceViewerComposable: ComponentActivity() {
//
//    private val presenceViewModel: PresenceViewModel by viewModels()
//
//    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
//        super.onCreate(savedInstanceState, persistentState)
//
//        if (savedInstanceState == null) {
//            presenceViewModel.ditto = DittoHandler.ditto
//            AndroidViewBinding(PresenceViewerFragmentLayoutBinding::inflate) {
//                val myFragment = fragmentContainerView.getFragment<PresenceViewerFragment>()
//                // ...
//            }
//        }
//    }
//
//}

@Composable
fun PresenceViewerDisplay(
    modifier: Modifier = Modifier,
    viewModel: MainViewModel,
    presenceViewModel: PresenceViewModel
){

    if(ditto == null){
        println("ditto is nulln 😅")
        return
    }else{
        println("we're good 👍🏽")
    }
    presenceViewModel.ditto = ditto

    AndroidViewBinding(factory = FragmentPresenceViewerBinding::inflate, modifier = modifier) {

        this.webview.webChromeClient = object : WebChromeClient() {

            override fun onConsoleMessage(message: ConsoleMessage): Boolean {
                Log.d(
                    "MyApplication", "${message.message()} -- From line " +
                            "${message.lineNumber()} of ${message.sourceId()}"
                )
                return true
            }
        }
    }
}