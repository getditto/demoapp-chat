/*
 * Copyright (c) 2018-2023 DittoLive.
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

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import live.ditto.Ditto
import live.ditto.DittoIdentity
import live.ditto.DittoLogLevel
import live.ditto.DittoLogger
import live.ditto.android.DefaultAndroidDittoDependencies
import live.dittolive.chat.DittoHandler.Companion.ditto

class SplashActivity : AppCompatActivity() {

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    setupDitto()

    val intent = Intent(this, NavActivity::class.java)
    startActivity(intent)
    finish()
  }

  private fun setupDitto() {
    DittoLogger.minimumLogLevel = DittoLogLevel.DEBUG

    val androidDependencies = DefaultAndroidDittoDependencies(applicationContext)
    ditto = Ditto(
      dependencies = androidDependencies,
      identity = resolveIdentity(androidDependencies)
    )
    ditto.setOfflineOnlyLicenseToken()

    // Disable sync with V3
    ditto.disableSyncWithV3()
    ditto.startSync()
  }

  /**
   * Returns [DittoIdentity.OnlinePlayground] for Debug builds,
   * [DittoIdentity.OfflinePlayground] otherwise.
   */
  private fun resolveIdentity(androidDependencies: DefaultAndroidDittoDependencies): DittoIdentity {
    if (BuildConfig.DEBUG) return DittoIdentity.OnlinePlayground(
      dependencies = androidDependencies,
      appId = BuildConfig.DITTO_APP_ID,
      token = BuildConfig.DITTO_PLAYGROUND_TOKEN
    )

    return DittoIdentity.OfflinePlayground(androidDependencies, BuildConfig.DITTO_APP_ID)
  }

  /**
   * Sets license token only on release build.
   */
  private fun Ditto.setOfflineOnlyLicenseToken() {
    if (BuildConfig.DEBUG) return

    setOfflineOnlyLicenseToken(BuildConfig.DITTO_OFFLINE_TOKEN)
  }
}
