package live.dittolive.chat

import live.ditto.DittoAuthenticationCallback
import live.ditto.DittoAuthenticator

class AuthCallback: DittoAuthenticationCallback {
    override fun authenticationRequired(authenticator: DittoAuthenticator) {
        authenticator.loginWithToken(BuildConfig.DITTO_AUTH_TOKEN, BuildConfig.DITTO_AUTH_PROVIDER) { err ->
            println("Login request completed. Error? $err")
        }
    }

    override fun authenticationExpiringSoon(
        authenticator: DittoAuthenticator,
        secondsRemaining: Long
    ) {
        authenticator.loginWithToken(BuildConfig.DITTO_AUTH_TOKEN, BuildConfig.DITTO_AUTH_PROVIDER) { err ->
            println("Login request completed. Error? $err")
        }
    }
}