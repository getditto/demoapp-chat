# ChatDemo-SwiftUI  

Basic Chat application written with Ditto and SwiftUI/Combine  

1. Clone this repo to a location on your machine, and open in Xcode    
2. Navigate to the project Signing & Capabilities tab and modify the Team and Bundle Identifier 
settings to your Apple developer account credentials to provision building to your device   
3. In Terminal, run `cp .env.template .env` at the root directory  
4. Edit `.env` to add environment variables as in the following example:  
```
APP_ID=a01b2c34-5d6e-7fgh-ijkl-8mno9p0q12r3
ONLINE_AUTH_TOKEN=ab01c2de-3f45-67g8-9012-34hi567j89k0
```
5. Clean (**Command + Shift + K**), then build (**Command + B**). This will generate `Env.swift`  
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
 
