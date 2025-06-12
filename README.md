# Ditto Chat

Internet-less cross platform chat application

This chat room demo showcases public and private chat rooms using Ditto.

Powered by [Ditto](https://ditto.live/).

For support, please contact Ditto Support (<support@ditto.live>).

- [Video Demo]() - pending
- [iOS Download](https://apps.apple.com/us/app/dittochat/id1450111256)
- [Android Download](https://play.google.com/store/apps/details?id=live.dittolive.chat)

Compatible with Android Automotive OS (AAOS)

## Features

#### Public chat - general
* Automatically join a public chat room with all nearby connected devices

#### Multiple public chat rooms

* Create new public chat rooms that anyone can browse and join

#### Private chat rooms
* Create private chat rooms and invite others to join by sharing a QR code

#### File attachments
* Inclue file attachments in chat messages

#### Delete and edit sent messages
* Delete or edit chat messages after they have already been sent

## Setup

Create an app in the Ditto Cloud Portal - https://portal.ditto.live

### iOS

1. Run the following command in the root directory of the iOS app:
```bash
cp .env.template .env
```
2. Open `.env` in a text editor or IDE such as VSCode and add the following environment variables, substituting your own values from the portal (`.env` will not show up in Xcode and is not to be mistaken for `Env.swift`)
```bash
DITTO_APP_ID=22389e28-9590-4cbf-b683-b3ac5ab2269e
DITTO_PLAYGROUND_TOKEN=62479eb9-9f23-46cf-907b-ab5309d46369
DITTO_WEBSOCKET_URL=wss://22389e28-9590-4cbf-b683-b3ac5ab2269e.cloud.ditto.live
```
3. Open the app project on Xcode and clean `(Command + Shift + K)`
4. Build the project `(Command + B)` (This will generate the `Env.swift`)

### Android

In the root directory of the Android app, create a new file `env.properties` and add the following environment variables, substituting your own values from the portal:
```bash
DITTO_APP_ID = 22389e28-9590-4cbf-b683-b3ac5ab2269e
DITTO_PLAYGROUND_TOKEN = 62479eb9-9f23-46cf-907b-ab5309d46369
DITTO_WEBSOCKET_URL = wss://22389e28-9590-4cbf-b683-b3ac5ab2269e.cloud.ditto.live
```

## License

MIT
