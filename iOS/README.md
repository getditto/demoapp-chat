# ChatDemo-SwiftUI  

Basic Chat application written with Ditto and SwiftUI/Combine  

1. Clone this repo to a location on your machine, and open in Xcode    
2. Navigate to the project Signing & Capabilities tab and modify the Team and Bundle Identifier 
settings to your Apple developer account credentials to provision building to your device   
3. In Terminal, run `cp .env.template .env` in the iOS directory  

4. Edit `.env` to add environment variables as in the following example, substituting your own values:
```
    DITTO_APP_ID = "replace with your app id"
    DITTO_PLAYGROUND_TOKEN = "replace with your playground token"
    DITTO_AUTH_PASSWORD = "replace with your auth password"
    DITTO_AUTH_PROVIDER = "replace with your auth provider"
    DITTO_OFFLINE_TOKEN = "replace with your offline license token"
```
* `DITTO_APP_ID` is the App ID used by Ditto; this needs to be the same on each device running the app in order for them to see each other, including across different platforms.
* `DITTO_PLAYGROUND_TOKEN` is the online playground token. This is used when using the online playground identity type.
* `DITTO_OFFLINE_TOKEN` is the offline-only playground token. This is used when using the offline playground identity type. Note this feature will be discontinued in the future.
* `DITTO_AUTH_PROVIDER` is the authentication provider name. This is used when using the online with authentication identity type.
* `DITTO_AUTH_PASSWORD` is the authentication password. This is used when using the online with authentication identity type.

5. Clean (**Command + Shift + K**), then build (**Command + B**). This will generate `Env.swift` in
the project directory  
6. Build to two iOS devices and sign in with distinct user names in the first screen  
7. Exchange messages in chat rooms between devices  

## Features  
- Basic text messaging.    
- Send image from Photos app as message. Thumbnail size image is replicated by default. See Settings 
`Enable Large Images` to receive full resolution images (~2.5MB). Note that fetching full resolution 
images from the mesh with only BLE transport enabled is slow (~25kb/sec).   
- Edit your own text messages.  
- Delete your own text and image messages.  
- Create public rooms to be used by all users on the P2P mesh.  
- Create private rooms for use only by users with a scanned QR code.  
- Archive/unarchive public and private rooms. Note that message data is evicted when archiving rooms 
and is only available again after replicating from a peer.   
 
