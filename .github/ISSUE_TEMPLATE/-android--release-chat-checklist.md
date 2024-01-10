---
name: "[Android] Release Chat Checklist"
about: A checklist for releasing Android Chat
title: "[Release] Android Chat"
labels: ''
assignees: ''

---

## References:
- [How to Publish Demo Apps](https://www.notion.so/getditto/How-to-Publish-Demo-Apps-4f00f8e544ac4402a4c450c0bf48649d)
- [How to Set Up Your Mac for Publishing Demo Apps](https://www.notion.so/getditto/How-to-Set-Up-Your-Mac-for-Publishing-Demo-Apps-aa53e4a74f1c44d3a1f8c26e708bd904)
- [Active Demo Apps List](https://www.notion.so/getditto/Active-Demo-Apps-List-60ccd64acbb74430b7f0d4db83bd412e)
- [Environment Variables](https://www.notion.so/getditto/Environment-Variables-78261e05a2b44a299ee388f06e9ff86a)

## Checklist:
1. - [ ] Assign yourself on this issue.
1. - [ ] Follow [the guide](https://www.notion.so/getditto/How-to-Set-Up-Your-Mac-for-Publishing-Demo-Apps-aa53e4a74f1c44d3a1f8c26e708bd904) to install the credential key.
1. - [ ] Make sure your `/Android/secure/` vars are the same as the ones listed in [Environment Variables](https://www.notion.so/getditto/Environment-Variables-78261e05a2b44a299ee388f06e9ff86a?pvs=4#f1d6b439dd70463c83956465159b7ed9); otherwise the app won't sync with the existing versions.
      - Run `cat Android/secure/release_creds.properties Android/secure/debug_creds.properties` to check vars.
1. - [ ] Make sure your branch is up to date (`git pull`).
1. - [ ] Test the Android Chat by syncing on multiple devices, opening PresenceViewer, etc.
1. - [ ] Test the cross-platform sync with [the iOS Chat](https://github.com/getditto/demoapp-chat/tree/main/iOS).
1. - [ ] Go to [Google Play Console](https://play.google.com/console/u/0/developers/6545405960643680014/app/4972464937857378467/tracks/production?tab=releases) and check the current released version number, then open this app with Android Studio and increment the version code in [app/build.gradle](https://github.com/getditto/demoapp-chat/blob/main/Android/app/build.gradle#L17).
1. - [ ] Generate a signed APK:
      - In Android Studio, click <kbd>Build</kbd> → <kbd>Generate Signed Bundle / APK...</kbd>.
      - Select <kbd>APK</kbd>, then click <kbd>Next</kbd>.
      - Click <kbd>Choose existing...</kbd> under `Key store path`, then choose `ditto-googleplay-key` you have placed in [demo-apps](https://github.com/getditto/ditto-apps). The path will look like this:
          - `<your_path_to_repo>/demo-apps/fastlane/credentials/ditto-googleplay-key`
      - Go to [Demo Apps Release - Android Key Store](https://my.1password.com/vaults/ks6bysyiuwyl4memcaidub5uuq/allitems/g2bdheq4vfnkvy5hlgcdo227zu) in 1Password, then click <kbd>Copy</kbd> on `password`.
      - Paste the password in both `Key store password` and `Key password`.
      - Enter the `key alias` showing in the [Demo Apps Release - Android Key Store](https://my.1password.com/vaults/ks6bysyiuwyl4memcaidub5uuq/allitems/g2bdheq4vfnkvy5hlgcdo227zu) in 1Password.
      - Check <kbd>Remember passwords</kbd>, then click <kbd>Next</kbd>.
      - Select <kbd>allRelease</kbd>, then click <kbd>Create</kbd>.
      - See the progress in the lower right on Android Studio.
      - The generated `app-all-release.apk` will be placed under `Android/app/all/release/`.
1. - [ ] Submit for Google's review:
      - Go to [the Production page in Google Play Console](https://play.google.com/console/u/0/developers/6545405960643680014/app/4972464937857378467/tracks/production), then click <kbd>Create new release</kbd>.
      - Click <kbd>Upload</kbd> under `App bundles`, then choose the `app-all-release.apk` you have generated above.
      - Edit the `Release notes` on the bottom of the page.
      - Click <kbd>Next</kbd> on the lower right, then click `Save` on the next page.
      - Go to [the app list](https://play.google.com/console/u/0/developers/6545405960643680014/app-list), and check Chat is `In Review`.
      - The review normally takes several hours, but sometimes it takes some days.
      - Once it's approved, it'll be released to Google Play Store automatically.
1. - [ ] You now have a git diff of the versioning. Cut a branch, open a pull request, and tie it to this issue.
1. - [ ] After the app is published to Google Play Store, merge the pull request created above (the version diffs).
1. - [ ] Install the published version from Google Play Store on devices and test it.


Once everything is done, please close this issue.
Please ask for help if there's any blocker.
