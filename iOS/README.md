# ChatDemo-SwiftUI  

Basic Chat application written with Ditto and SwiftUI/Combine  

1. Clone this repo to a location on your machine, and open in Xcode    
2. Navigate to the project Signing & Capabilities tab and modify the Team and Bundle Identifier 
settings to your Apple developer account credentials to provision building to your device   
3. In Terminal, run `cp .env.template .env` in the iOS directory  
4. Edit `.env` to add environment variables as in the following example:  
```
DITTO_APP_ID=replace_with_your_app_id
DITTO_PLAYGROUND_TOKEN=replace_with_your_playground_token
```
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
 
