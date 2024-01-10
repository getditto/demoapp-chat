---
name: "[iOS] Release Chat Checklist"
about: A checklist for releasing iOS Chat
title: "[Release] iOS Chat"
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
1. - [ ] Run `bundle exec fastlane install_certificate` on [demo-apps](https://github.com/getditto/demo-apps) to install the latest iOS Certificate on Mac. (See [How to Set Up Your Mac for Publishing Demo Apps](https://www.notion.so/getditto/How-to-Set-Up-Your-Mac-for-Publishing-Demo-Apps-aa53e4a74f1c44d3a1f8c26e708bd904))
1. - [ ] Make sure your `.env` vars are the same as the ones listed in [Environment Variables](https://www.notion.so/getditto/Environment-Variables-78261e05a2b44a299ee388f06e9ff86a?pvs=4#da3ac437bd0a4198bc8080b513b06ec2); otherwise the app won't sync with the existing versions.
1. - [ ] Make sure your branch is up to date (`git pull`).
1. - [ ] Test the iOS Chat by syncing on multiple devices, opening PresenceViewer, etc.
1. - [ ] Test the cross-platform sync with [the Android Chat](https://github.com/getditto/demoapp-chat/tree/main/Android).
1. - [ ] Go to [App Store Connect](https://appstoreconnect.apple.com/apps/1450111256/appstore/ios/version/deliverable) and check the current released version number, then open Xcode to increment version ([image](https://github.com/getditto/demoapp-inventory/assets/26117257/df1226f1-c0e8-4dfe-970e-c6da46fa6a11)). Normally following [the semantic versioning](https://semver.org/).
1. - [ ] Upload the app to App Store Connect:
        - In Xcode, click <kbd>Product</kbd> → <kbd>Archive</kbd>, then click <kbd>Distribute App</kbd> → <kbd>TestFlight & App Store</kbd> → <kbd>Distribute</kbd>
        - If there's an error, add a comment on this issue to ask for help if needed
1. - [ ] You now have a git diff of the versioning. Cut a branch, open a pull request, and tie it to this issue.
1. - [ ] Submit for Apple's review:
      - Click <kbd>+</kbd> on the upper left ([image](https://github.com/getditto/demoapp-inventory/assets/26117257/4f30f1a4-4fd9-466c-b5b6-6a8c8bd74ece)), then type the version you used to archive the app in above. Please don't mistype this.
      - Fill `What's New in This Version`. ([image](https://github.com/getditto/demoapp-inventory/assets/26117257/c2687a73-0b4a-45e1-9785-8f186af61b65))
      - Select the build you have uploaded above. ([image](https://github.com/getditto/demoapp-inventory/assets/26117257/f872d4ea-1eb0-42a5-af81-32567e16bb9e))
      - Click <kbd>Save</kbd> and <kbd>Add for Review</kbd> on upper right, then click the submit button on the next screen
      - Make sure the app status is `Waiting for review`. ([image](https://github.com/getditto/demoapp-inventory/assets/26117257/8825e8f5-c156-4bbc-aedb-73f85e126543))
      - The review normally takes several hours, but sometimes it takes some days.
      - If rejected, add a comment on this issue for visibility and ask for help if needed.
      - Once it's approved, it'll be automatically released to AppStore since it's set to `Automatically release this version`.
1. - [ ] After the app is published to AppStore, merge the pull request created above (the version diffs).
1. - [ ] Install the published version from AppStore on devices and test it.

Once everything is done, please close this issue.
Please ask for help if there's any blocker.
