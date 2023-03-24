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

import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.toInstant

//fun Long.toDateTimeString(zoneOffset: ZoneOffset = ZoneOffset.UTC): String? {
//  return try {
//    val instant = Instant.ofEpochMilli(this)
//    val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS")
//
//    val zdtDefault = instant.atOffset(zoneOffset)
//    return zdtDefault.format(formatter)
//
//  } catch (e: Exception) {
//    e.toString()
//  }
//}

//fun String.toIso8601(): Date? {
//  val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault())
//  val date: Date? = formatter.parse(this)
//  return date
//}

fun String.toInstant(): kotlinx.datetime.Instant? {
  return this.toInstant()
//  return LocalDateTime.parse(this)
}

//fun String.toIso8601String(): String? {
//  val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault())
//  val date: Date? = formatter.parse(this)
//  return date?.toString()
//}

fun LocalDateTime.toIso8601String() : String {
  var dateString =  this.toString()
  var dateParts = dateString.split(".")
  dateString = dateParts[0]
  dateString += "Z"
  return dateString
}