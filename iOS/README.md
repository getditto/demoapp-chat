# ChatDemo-SwiftUI  

## Basic Chat application written with Ditto and SwiftUI/Combine  

### Setup

Credentials live in a single `.env` at the repository root, shared by both apps. See the
[root README](../README.md#setup) to create a database in the
[Ditto Cloud Portal](https://portal.ditto.live) and fill in `.env`. Then build the iOS app:

1. Open the app project in Xcode and clean `(Command + Shift + K)`.
2. Navigate to the project Signing & Capabilities tab and modify the Team and Bundle Identifier
settings to your Apple developer account credentials to provision building to your device.
3. Build the project `(Command + B)`. The build reads the root `.env` and generates `Env.swift`
(which is not to be mistaken for `.env` and does not show up in Xcode).

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
 
