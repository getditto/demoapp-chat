# ChatDemo-Android

## Basic Chat application written with Ditto and Kotlin

### Setup

1. Create an app in the Ditto Cloud Portal - https://portal.ditto.live
2. In the root directory of the Android app, create a new file `env.properties` and add the following environment variables, substituting your own values from the portal:
```bash
DITTO_APP_ID = replace_with_your_app_id
DITTO_PLAYGROUND_TOKEN = replace_with_your_playground_token
DITTO_WEBSOCKET_URL = replace_with_your_websocket_url
```

### Features

- Dependency Injection via Hilt
- Coroutines
- LiveData
- Flows
- Compose
- Reactive Architecture

### Known Issues

- Only default public room available on Android at this time
- changing user profile photo is not yet supported
- file attachments are not yet supported

### Copyright

Copyright (c) 2022 DittoLive

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
In the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

This project and source code may use libraries or frameworks that are
released under various Open-Source licenses. Use of those libraries and
frameworks are governed by their own individual licenses.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
