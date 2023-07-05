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

import android.graphics.Bitmap
import live.dittolive.chat.conversation.Message
import java.io.InputStream

/**
 * a [Message] with additional user information
 */
data class MessageUiModel (
    val message: Message,
    val user: User,
    val id: String = message._id
        ) {
    companion object {
        operator fun invoke(message: Message, users: List<User>) : MessageUiModel {
            var messageSender: User? = null
            for (user in users) {
                if (user.id == message.userId) {
                    messageSender = user
                }
            }
            messageSender?.let {
                return MessageUiModel(user = messageSender, message = message)
            }
            val noUserFound = User()
            return MessageUiModel(user = noUserFound, message = message)
        }
    }
    constructor(message: Message, user: User) : this(
        id = message._id,
        message = message,
        user = user
    )
}