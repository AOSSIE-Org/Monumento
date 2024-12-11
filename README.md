<div align="center">
 <span>
 <img src="assets/cover.png" alt="Resonate logo" width="800" height="auto" />
 </span>
<br><br>

# Monumento 🌎
 </div>
 <div align="center">

[![Discord Follow](https://dcbadge.vercel.app/api/server/6mFZ2S846n?style=flat)](https://discord.gg/6mFZ2S846n) &ensp;&ensp;
[![License:GPL-3.0](https://img.shields.io/badge/License-GPL-yellow.svg)](https://opensource.org/license/gpl-3-0/)&ensp;&ensp;
![GitHub Org's stars](https://img.shields.io/github/stars/AOSSIE-Org/monumento?style=social)

</div>
Monumento is an AR-integrated social app that transforms how you connect with the world’s most iconic landmarks. Through Monumento, you can check in to popular monuments, explore famous sites, and discover new people, all within a social platform dedicated to cultural and historical experiences. Whether you're a traveler or a history enthusiast, Monumento offers an immersive way to engage with the world’s most treasured locations.

## 💻 Technologies Used
- Dart
- Flutter
- Firebase

## 🖥️ How to setup locally
Clone the project

```
  git clone https://github.com/AOSSIE-Org/Monumento.git
```

Go to the project directory

```
  cd Monumento
```

Install dependencies

```
  flutter pub get
```

Create `.env` using template `.env.template` and add API keys
```
cat .env.template > .env
```

Add the following API keys to the `.env` file

- `GOOGLE_SIGNIN_ANDROID_CLIENT_ID`: Obtain this from the Google Cloud Console for Android configuration.
- `GOOGLE_SIGNIN_APPLE_CLIENT_ID`: Obtain this from the Google Cloud Console for iOS configuration.
- `GOOGLE_SIGNIN_WEB_CLIENT_ID`: Obtain this from the Google Cloud Console for web configuration.
- `GEOAPIFY_API_KEY`: Obtain this from the [Geoapify](https://www.geoapify.com/) website for fetching location.

Refer to the updated guide below for obtaining these API keys:

- [Google Cloud Console Guide](https://developers.google.com/identity) for Google Sign-In.
- [Geoapify API Setup](https://www.geoapify.com/get-started-with-maps-api/)

## Configure Firebase
Follow the official [Firebase guide](https://firebase.google.com/docs/flutter/setup?platform=android) to set it up for this project. This will:

- Add the `google-services.json` file for Android.
- Add the `GoogleService-Info.plist` file for iOS and MacOS.
- Create the `firebase_options.dart` file in the lib folder.



## ✌️ Maintainers

-   [Jaideep Prasad](https://github.com/jddeep)
-   [Chandan S Gowda](https://github.com/chandansgowda)


## 🙌 Contributing
⭐ Don't forget to star this repository if you find it useful! ⭐

Thank you for considering contributing to this project! Contributions are highly appreciated and welcomed. To ensure a smooth collaboration, Refer to the [Contribution Guidelines](https://github.com/AOSSIE-Org/Monumento/blob/master/contributing.md).

We appreciate your contributions and look forward to working with you to make this project even better!

By following these guidelines, we can maintain a productive and collaborative open-source environment. Thank you for your support!


## 📍 License

Distributed under the [GNU General Public License](https://opensource.org/license/gpl-3-0/). See [LICENSE](https://github.com/AOSSIE-Org/Monumento/blob/master/LICENSE) for more information.

## 📫 Communication Channels
If you have any questions, need clarifications, or want to discuss ideas, feel free to reach out through the following channels:

[Discord Server](https://discord.com/invite/6mFZ2S846n)\
[Email](aossie.oss@gmail.com)

## Made by the Community, with ❤️

<a href="https://github.com/AOSSIE-Org/monumento/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=AOSSIE-Org/monumento" alt="Contributors"/>
</a>
<br>