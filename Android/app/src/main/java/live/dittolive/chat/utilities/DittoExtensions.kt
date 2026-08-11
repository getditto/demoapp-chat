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

package live.dittolive.chat.utilities

import com.ditto.kotlin.DittoQueryResultItem
import org.json.JSONArray
import org.json.JSONObject

/**
 * Returns the document as a plain [Map] keyed by field name. The query result item exposes its
 * fields as a CBOR dictionary; the model constructors consume a string-keyed map, so the document
 * is read through its JSON representation. Nested objects become [Map]s and arrays become [List]s.
 */
fun DittoQueryResultItem.toFieldMap(): Map<String, Any?> = JSONObject(jsonString()).toFieldMap()

fun JSONObject.toFieldMap(): Map<String, Any?> = keys().asSequence().associateWith { key ->
    when (val value = get(key)) {
        is JSONObject -> value.toFieldMap()
        is JSONArray -> value.toValueList()
        JSONObject.NULL -> null
        else -> value
    }
}

fun JSONArray.toValueList(): List<Any?> = (0 until length()).map { index ->
    when (val value = get(index)) {
        is JSONObject -> value.toFieldMap()
        is JSONArray -> value.toValueList()
        JSONObject.NULL -> null
        else -> value
    }
}
