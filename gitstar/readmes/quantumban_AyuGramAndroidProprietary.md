## What's this fork even about?

It's fork of [AyuGram for Android](https://github.com/AyuGram/AyuGram4A) ~~"without proprietary"~~ with no hidden source files and with **full code transparency unlike [original project](https://github.com/AyuGram/AyuGram4A)**. If you don't trust Github Actions, just [build apk by yourself](#where-do-i-find-apk)!

The differences between original project and this fork:
1. [Reverse engineered source files that was hidden in private repository](https://github.com/Dr4iv3rNope/NotSoAndroidAyuGram/tree/rewrite/TMessagesProj/src/main/java/com/radolyn/ayugram/proprietary)
2. You can build that application by yourself and forget about "implementing AyuHistoryHook and AyuMessageUtils"
2. AyuStinc(Sync) removed
3. [You can download APK directly from this repository](https://github.com/Dr4iv3rNope/NotSoAndroidAyuGram/actions)

Other information about original project you can find [here](https://github.com/AyuGram/AyuGram4A/blob/rewrite/README.md)

## Where do i find APK?

There's multiple ways to get AyuGram:

1. **[Download builded .apk from Github Actions](https://github.com/Dr4iv3rNope/NotSoAndroidAyuGram/actions)**
2. [Build it using Android Command Line Tools](#build-via-android-command-line-tools)
3. [Build it using Github Actions](#set-up-github-actions)
3. [Build it using Android Studio](#build-via-android-studio)

### Build via Android Command Line Tools

Ensure you have installed [Android Command Line Tools](https://developer.android.com/tools)

1. **Clone this repository**

   `git clone https://github.com/Dr4iv3rNope/NotSoAndroidAyuGram.git`

2. **Navigate to repository**

   `cd NotSoAndroidAyuGram`

3. **Create "local.properties" and add "sdk.dir" variable**

   ```
   sdk.dir=/path/to/android-sdk
   ```

4. **Generate signing keys**

   Command example: `keytool -genkey -v -keystore release-key.keystore -alias release-key-alias -keyalg RSA -keysize 2048 -validity 10000`

5. **Put generated .keystore file to TMessagesProj/config/extera.jks**

   `mv release-key.keystore TMessagesProj/config/extera.jks`

6. **Create API_KEYS file with following content**

   ```
   APP_ID = 6
   APP_HASH = "eb06d4abfb49dc3eeb1aeb98ae0f581e"
   MAPS_V2_API = <...>

   SIGNING_KEY_PASSWORD = myPassword
   SIGNING_KEY_ALIAS = release-key-alias
   SIGNING_KEY_STORE_PASSWORD = myPassword
   ```

7. **Get Google Firebase "google-services.json" configuration file**

   It's required... So just generate it using [this instruction](https://firebase.google.com/docs/android/setup)

8. **Add "google-services.json" to this project**

   Put this file into `TMessageProj/google-services.json`

9. **Build APK!**

   Build APK using `./gradlew <Task name>`

   If you're not sure about your devices ABI,
   just build using `./gradlew assembleAfat`

   | Task name | Output APK ABI |
   | :-------- | :---------- |
   | assembleAfat | **(Recomended)** **"universal apk"** that can be used on all devices |
   | assembleArm64 | **arm64-v8a** |
   | assembleArmv7 | **armeabi-v7a** |
   | assembleX64 | **x86_64** |
   | assembleX86 | **x86** |

   Other tasks can be listed using `./gradlew tasks`

### Set up Github Actions

#### You can generate base64 string via:
- Linux terminal: `base64 <filename>`
- Powershell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("<filename>"))`

1. Generate keystore file [(it's <u>4th step</u> from the command line tools build instruction)](#build-via-android-command-line-tools) and [convert it into base64](#you-can-generate-base64-string-via)
2. Generate google-services.json file and [convert it into base64](#you-can-generate-base64-string-via)
3. [Go to repository settings > Secrets and variables > Actions](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)
4. Add **SIGNING_KEYSTORE_FILE_IN_BASE64** secret with **base64 string generated from <u>1st step</u>**
5. Add **GOOGLE_SERVICES_JSON_FILE_IN_BASE64** secret with **base64 string generated from <u>2nd step</u>**
6. Add **SIGNING_KEY_PASSWORD** secret with **keystore file password** value
7. Add **SIGNING_KEY_ALIAS** secret with **keystore alias name** value
8. Now you're ready to [run build workflow](https://docs.github.com/en/actions/using-workflows/manually-running-a-workflow#running-a-workflow)!

### Build via Android Studio

Android studio can be downloaded [here](https://developer.android.com/studio)

1. Clone this repository
2. Open the project in Android Studio. It should be opened, **not imported**
3. [Generate](https://firebase.google.com/docs/android/setup) and replace `google-services.json` ([he](https://github.com/ZavaruKitsu) don't want to see crash reports from your app...)
4. Generate signing keys and fill API_KEYS
5. Build it!

## AyuGram Localization

[![Crowdin](https://badges.crowdin.net/ayugram/localized.svg)](https://crowdin.com/project/ayugram)
[![Crowdin](https://badges.crowdin.net/exteralocales/localized.svg)](https://crowdin.com/project/exteralocales)

We have our own **[Crowdin](https://crowdin.com/project/ayugram)**.

But since **AyuGram** is based on **exteraGram**, also join their project
at **[Crowdin](https://crowdin.com/project/exteralocales)**!

## Credits

- **[exteraGram](https://github.com/exteraSquad/exteraGram)**
- [Telegraher](https://github.com/nikitasius/Telegraher)
- [Cherrygram](https://github.com/arsLan4k1390/Cherrygram)
- [Nagram](https://github.com/NextAlone/Nagram)
- [Telegram FOSS](https://github.com/Telegram-FOSS-Team/Telegram-FOSS)
