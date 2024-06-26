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

package live.dittolive.chat.data.model

import live.ditto.DittoDocument
import live.dittolive.chat.data.collectionIdKey
import live.dittolive.chat.data.createdByKey
import live.dittolive.chat.data.createdOnKey
import live.dittolive.chat.data.dbIdKey
import live.dittolive.chat.data.firstNameKey
import live.dittolive.chat.data.isPrivateKey
import live.dittolive.chat.data.lastNameKey
import live.dittolive.chat.data.messagesIdKey
import live.dittolive.chat.data.nameKey
import java.util.UUID

data class User(
    val id: String = UUID.randomUUID().toString(),
    val firstName: String = "",
    val lastName: String = "",
    val fullName: String = "$firstName $lastName"
) {
    constructor(item: Map<String, Any?>) :this(
        item[dbIdKey] as String,
        item[firstNameKey] as String,
        item[lastNameKey] as String
    )
}
