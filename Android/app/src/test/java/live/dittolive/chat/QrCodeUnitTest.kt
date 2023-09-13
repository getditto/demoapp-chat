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

import live.dittolive.chat.utilities.PrivateRoomQrCode
import live.dittolive.chat.utilities.parsePrivateRoomQrCode
import org.junit.Assert.assertEquals
import org.junit.Test

class QrCodeUnitTest {
    /**
     * Given a correct QR Code string,
     * When parsing the string,
     * Then should produce a valid [PrivateRoomQrCode]
     */
    @Test
    fun parse_correct_string() {
        // given
        val qrCodeStr = "part1\npart2\npart3"

        // when
        val privateRoomQrCode = parsePrivateRoomQrCode(qrCodeStr)

        // then
        val expected = PrivateRoomQrCode(
            roomId = "part1",
            collectionId = "part2",
            messagesId = "part3",
        )
        assertEquals(expected, privateRoomQrCode)
    }

    /**
     * Given an incorrect QR Code string,
     * When parsing the string,
     * Then should produce null
     */
    @Test
    fun parse_incorrect_string() {
        // given
        val qrCodeStr = "part1\npart2"

        // when
        val privateRoomQrCode = parsePrivateRoomQrCode(qrCodeStr)

        // then
        assertEquals(null, privateRoomQrCode)
    }
}