package live.dittolive.chat.utilities

import live.dittolive.chat.data.collectionIdKey
import live.dittolive.chat.data.dbIdKey
import live.dittolive.chat.data.messagesIdKey

data class PrivateRoomQrCode(
    val roomId: String,
    val collectionId: String,
    val messagesId: String,
)

fun PrivateRoomQrCode.toMap() = mapOf(
    dbIdKey to roomId,
    collectionIdKey to collectionId,
    messagesIdKey to messagesId,
)

/**
 * Parses the given QR Code string representation.
 * Returns [PrivateRoomQrCode] if parsing was successful, null otherwise
 */
fun parsePrivateRoomQrCode(qrCode: String): PrivateRoomQrCode? {
    val parts = qrCode.split("\n")
    if (parts.size != 3) return null

    return PrivateRoomQrCode(
        roomId = parts[0],
        collectionId = parts[1],
        messagesId = parts[2],
    )
}