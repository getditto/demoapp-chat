# Ditto Chat

Internet-less cross platform chat application

This chat room demo showcases public and private chat rooms using Ditto.

Powered by [Ditto](https://www.ditto.com/).

For support, please contact Ditto Support (<support@ditto.com>).

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

Create a database in the Ditto Cloud Portal - https://portal.ditto.live

Both the iOS and Android apps read their credentials from a single `.env` file in the
repository root. From the repository root:

1. Copy the template:
```bash
cp .env.example .env
```
2. Open `.env` and substitute your own values from the portal:
```bash
DITTO_DATABASE_ID=replace_with_your_database_id
DITTO_DEVELOPMENT_TOKEN=replace_with_your_development_token
DITTO_SERVER_URL=replace_with_your_url
```
`.env` is gitignored and is shared by both platforms.

### iOS

1. Open the app project in Xcode and clean `(Command + Shift + K)`.
2. In the project's Signing & Capabilities tab, set the Team and Bundle Identifier to your Apple
developer account to provision building to your device.
3. Build the project `(Command + B)` — the build reads the root `.env` and generates `Env.swift`.

### Android

Open the `Android` project in Android Studio and build/run — the Gradle build reads the root
`.env` automatically. No additional setup is required beyond the root `.env` above.

## License

MIT
