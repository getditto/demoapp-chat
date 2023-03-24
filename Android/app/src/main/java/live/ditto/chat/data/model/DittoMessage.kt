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

package live.ditto.chat.data.model

import androidx.compose.runtime.Immutable
import live.ditto.DittoDocument
import live.ditto.chat.R
import live.ditto.chat.data.createdOnKey
import live.ditto.chat.data.roomIdKey
import live.ditto.chat.data.textKey
import live.ditto.chat.data.userIdKey
import java.util.*

@Immutable
data class DittoMessage(
    val _id: String = UUID.randomUUID().toString(),
    val createdOn: String,
    val roomId: String = "public", // "public" is the roomID for the default public chat room
    val text: String,
    val userId: String,
    val image: Int? = null,
    val authorImage: Int = if (userId == "me") R.drawable.fuad else R.drawable.someone_else
) {
    constructor(document: DittoDocument) :this(
        document["_id"].stringValue,
        document[createdOnKey].stringValue,
        document[roomIdKey].stringValue,
        document[textKey].stringValue,
        document[userIdKey].stringValue
    )
}