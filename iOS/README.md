# ChatDemo-SwiftUI  

## Basic Chat application written with Ditto and SwiftUI/Combine  

### Setup


1. Create an app in the Ditto Cloud Portal - https://portal.ditto.live
2. Run the following command in the root directory of the iOS app:
```bash
cp .env.template .env
```
3. Open `.env` in a text editor or IDE such as VSCode and add the following environment variables, substituting your own values from the portal (`.env` will not show up in Xcode and is not to be mistaken for `Env.swift`)
```bash
DITTO_APP_ID=replace_with_your_app_id
DITTO_PLAYGROUND_TOKEN=replace_with_your_playground_token
DITTO_WEBSOCKET_URL=replace_with_your_websocket_url
```
4. Open the app project on Xcode and clean `(Command + Shift + K)`
5. Navigate to the project Signing & Capabilities tab and modify the Team and Bundle Identifier 
settings to your Apple developer account credentials to provision building to your device
6. Build the project `(Command + B)` (This will generate the `Env.swift`)

### Features

- Basic text messaging.    
- Send image from Photos app as message. Thumbnail size image is replicated by default. See Settings 
Enable Large Images to receive full resolution images (~2.5MB). Note that fetching full resolution 
images from the mesh with only BLE transport enabled is slow (~25kb/sec).   
- Edit your own text messages.  
- Delete your own text and image messages.  
- Create public rooms to be used by all users on the P2P mesh.  
- Create private rooms for use only by users with a scanned QR code.  
- Archive/unarchive public and private rooms. Note that message data is evicted when archiving rooms 
and is only available again after replicating from a peer.   
 
