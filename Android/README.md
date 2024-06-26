# ChatDemo-Android

Android version of the Chat App Demo

## Features

- Dependency Injection via Hilt
- Coroutines
- LiveData
- Flows
- Compose
- Reactive Architecture

## Known Issues

- Only default public room available on Android at this time
- changing user profile photo is not yet supported
- file attachments are not yet supported

## Building the App

You need to setup some environment variables in order to build this project:

1. Copy the provided `env.properties.example` file to `env.properties`
2. Create an app in the Ditto Cloud Portal - https://portal.ditto.live
3. Update the ignored `env.properties` file adding the corresponding values from your app:

```
# Environment Variables  

DITTO_APP_ID = replace_with_your_app_id
DITTO_PLAYGROUND_TOKEN = replace_with_your_playground_token
```

- `DITTO_APP_ID` is the App ID used by Ditto; this needs to be the same on each device running the
  app in order for them to see each other, including across different platforms.
- `DITTO_PLAYGROUND_TOKEN` is the online playground token. This is used when using the online
  playground identity type.

## Copyright

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
