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

import android.content.Context
import live.ditto.Ditto
import live.ditto.DittoIdentity
import live.ditto.DittoLogLevel
import live.ditto.DittoLogger
import live.ditto.android.DefaultAndroidDittoDependencies

class DittoHandler {
    companion object {
        lateinit var ditto: Ditto

        /**
         * Configures Ditto and starts the sync process
         *
         * @param applicationContext: The application context
         * @param onInitialized: Invoke when Ditto is initialized
         * @param onError: Invoke on any error during initialization
         */
        fun setupAndStartSync(
            applicationContext: Context,
            onInitialized: () -> Unit,
            onError: (error: Throwable) -> Unit,
        ) {
            if (::ditto.isInitialized) return onInitialized()

            try {
                DittoLogger.minimumLogLevel = DittoLogLevel.DEBUG

                val androidDependencies = DefaultAndroidDittoDependencies(applicationContext)

                ditto = Ditto(
                    dependencies = androidDependencies,
                    identity = resolveIdentity(androidDependencies)
                ).apply {
                    setOfflineOnlyLicenseToken()
                    disableSyncWithV3()
                    startSync()
                }
            } catch (e: Throwable) {
                return onError(e)
            }

            onInitialized()
        }
    }
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