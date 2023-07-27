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

<<<<<<<< HEAD:Android/app/src/main/java/live/dittolive/chat/app/dependencyinjection/ChatRoomDBModule.kt
package live.dittolive.chat.app.dependencyinjection

import android.content.Context
import androidx.room.Room
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import live.dittolive.chat.data.DATABASE_NAME
import live.dittolive.chat.data.db.ChatDatabase
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object ChatRoomDBModule {

    @Singleton
    @Provides
    fun provideChatRoomDatabase(
        @ApplicationContext context: Context
    ): ChatDatabase =
        Room.databaseBuilder(
            context,
            ChatDatabase::class.java,
            DATABASE_NAME
        ).build()

    @Singleton
    @Provides
    fun provideChatRoomDao(database: ChatDatabase) = database.roomsDao()

========
package live.dittolive.chat.utilities

import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.periodUntil

fun String.isoToTimeAgo(): String {
    return try {
        val instant = Instant.parse(this)
        val now = Clock.System.now()
        val timeZone = TimeZone.currentSystemDefault()

        val period = instant.periodUntil(now, timeZone)
        val days = period.days
        val hours = period.hours
        val minutes = period.minutes
        val seconds = period.seconds

        when {
            days > 0 -> "$days day${if (days > 1) "s" else ""} ago"
            hours > 0 -> "$hours hour${if (hours > 1) "s" else ""} ago"
            minutes > 0 -> "$minutes minute${if (minutes > 1) "s" else ""} ago"
            else -> "$seconds second${if (seconds > 1) "s" else ""} ago"
        }
    } catch (e: Exception) {
        "Invalid date"
    }
    return this
>>>>>>>> main:Android/app/src/main/java/live/dittolive/chat/utilities/Extensions.kt
}