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

package live.ditto.chat.utilities

import android.Manifest
import android.os.Build

class Permissions() {

    /**
     * Calculate the list of missing permissions.
     *
     * The returned value can be passed directly to `ActivityCompat.requestPermissions()`.
     */
//    fun missingPermissions(permissions: Array<String> = requiredPermissions()): Array<String> {
//        val missing = mutableListOf<String>()
//        for (permission in permissions) {
//            if (isMissing(permission, context)) {
//                Log.e(TAG, "Missing permission $permission")
//                missing.add(permission)
//            }
//        }
//        return missing.toTypedArray()
//    }

    private fun requiredBluetoothClientPermissions(): List<String> {
        val required = mutableListOf<String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12+ (API 31+)
            required.add(Manifest.permission.BLUETOOTH_CONNECT)
            /*
              Since Ditto's BLE isn't used directly for locating physical position, we will
              advise customers to indicate the `neverForLocation` flag:

                <uses-permission android:name="android.permission.BLUETOOTH_SCAN"
                     android:usesPermissionFlags="neverForLocation"
                     tools:targetApi="s" />

              If the app developer wishes they can request ACCESS_FINE_LOCATION instead, but
              we will not try to detect that here.
             */
            required.add(Manifest.permission.BLUETOOTH_SCAN)
        }
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.R) {
            // Android 6 through 11 (API 23-30) require location access for BLE scanning operation
            required.add(Manifest.permission.ACCESS_FINE_LOCATION)
        }
        return required
    }

    private fun requiredBluetoothServerPermissions(): List<String> {
        val required = mutableListOf<String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12+ (API 31+)
            required.add(Manifest.permission.BLUETOOTH_ADVERTISE)
            required.add(Manifest.permission.BLUETOOTH_CONNECT)
        }
        return required
    }

    private fun requiredWifiAwarePermissions(): List<String> {
        val required = mutableListOf<String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+ (API 33+)
            required.add(Manifest.permission.NEARBY_WIFI_DEVICES)
        }
        else {
            // WiFi Aware requires location access on Android 10-12L (API 29-32)
            required.add(Manifest.permission.ACCESS_FINE_LOCATION)
            // ACCESS_COARSE_LOCATION not required
        }
        return required
    }

    /**
     * Builds a list of all required permissions that involve UI interaction.
     */
    fun requiredPermissions(): List<String> {
        val required = mutableListOf<String>()
        required.addAll(requiredBluetoothClientPermissions())
        required.addAll(requiredBluetoothServerPermissions())
        required.addAll(requiredWifiAwarePermissions())
        // Dedupe list with `distinct`
        return required.distinct()
    }
}