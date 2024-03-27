# Monumento
An AR integrated social app for sharing landmarks, visited places and visualizing their 3D models right from a mobile device


## 💻 Technologies Used
- Java
- Kotlin
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
Monumento requires Flutter version to be less than 3.10.0. If your version is more than 3.10.0, you can follow the below steps or downgrade your local version of Flutter

1. Install [FVM](https://fvm.app)
2. Install Flutter 3.7.12 through FVM
    ```
    fvm install 3.7.12
    ```
3. Once installed, run the following command to set it as the default version for FVM
    ```
    fvm use 3.7.12
    ```
4. Now open a terminal and move to the `monumento_module` directory
5. Upgrade the dependencies
    ```
    fvm flutter pub upgrade
    ```
6. Now try running the app
    ```
    fvm flutter run
    ```

Follow the official [Firebase guide](https://firebase.google.com/docs/flutter/setup?platform=android) to set it up for this project. This will add the `google-services.json` and `GoogleService-Info.plist` file for android and iOS, and also creates a `firebase_options.dart` file in the lib folder

Enable [Google Cloud Vision API](https://console.cloud.google.com/marketplace/product/google/vision.googleapis.com) in GCP and generate a private key. In android folder, open `local.properties` file. Create it if it doesn't exist and add the following line
```
cloud.vision.api.key=abcd_your_api_key_here_xyz
```
\
Tip: If you are using VS Code, create `.vscode/seetings.json` file if doen't already exist and add the following lines
```
{
    "dart.flutterSdkPath": "/path/to/fvm/versions/3.7.12", //example path: "/Users/xyz/fvm/versions/3.7.12"
    // Remove .fvm files from search
    "search.exclude": {
      "**/.fvm": true
    },
    // Remove from file watching
    "files.watcherExclude": {
      "**/.fvm": true
    }
  }
  ```

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
