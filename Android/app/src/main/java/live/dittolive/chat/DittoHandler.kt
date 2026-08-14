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

import com.ditto.kotlin.Ditto
import com.ditto.kotlin.DittoAuthenticationProvider
import com.ditto.kotlin.DittoConfig
import com.ditto.kotlin.DittoFactory
import com.ditto.kotlin.DittoLogLevel
import com.ditto.kotlin.DittoLogger

class DittoHandler {
    companion object {
        lateinit var ditto: Ditto

        /**
         * Configures Ditto and starts the sync process.
         *
         * @param onInitialized: Invoke when Ditto is initialized
         * @param onError: Invoke on any error during initialization
         */
        suspend fun setupAndStartSync(
            onInitialized: () -> Unit,
            onError: (error: Throwable) -> Unit,
        ) {
            if (::ditto.isInitialized) return onInitialized()

            try {
                DittoLogger.minimumLogLevel = DittoLogLevel.Debug

                require(BuildConfig.DITTO_DATABASE_ID.isNotBlank()) { "DITTO_DATABASE_ID is missing. Set it in .env before building." }
                require(BuildConfig.DITTO_DEVELOPMENT_TOKEN.isNotBlank()) { "DITTO_DEVELOPMENT_TOKEN is missing. Set it in .env before building." }
                require(BuildConfig.DITTO_SERVER_URL.isNotBlank()) { "DITTO_SERVER_URL is missing. Set it in .env before building." }
                require(BuildConfig.DITTO_SERVER_URL.startsWith("https://")) {
                    "DITTO_SERVER_URL must be an https:// URL (the v5 portal \"Connect via SDK\" URL): \"${BuildConfig.DITTO_SERVER_URL}\""
                }

                // Get your Database ID and URL from the Ditto Portal: https://portal.ditto.live/
                val config = DittoConfig(
                    databaseId = BuildConfig.DITTO_DATABASE_ID,
                    connect = DittoConfig.Connect.Server(BuildConfig.DITTO_SERVER_URL)
                )

                // The Android context is supplied internally via AndroidX App Startup.
                ditto = DittoFactory.create(config)

                // The development token authenticates this device against the online playground.
                // The handler runs once at launch and again before the token expires, and must be
                // set before sync starts.
                ditto.auth?.expirationHandler = { dittoInstance, _ ->
                    dittoInstance.auth?.login(
                        BuildConfig.DITTO_DEVELOPMENT_TOKEN,
                        DittoAuthenticationProvider.development()
                    )
                }

                // Sync is peer-to-peer only. This demo is shared among many users, so the WebSocket
                // (cloud) connection list is left empty to keep public-room messages from mixing
                // through a shared Big Peer.
                ditto.updateTransportConfig { transportConfig ->
                    transportConfig.connect.websocketUrls = mutableSetOf()
                }

                // https://docs.ditto.live/sdk/latest/sync/start-and-stop-sync
                ditto.sync.start()

            } catch (e: Throwable) {
                return onError(e)
            }

            onInitialized()
        }
    }
}
