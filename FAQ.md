# FAQ and Issue Reporting Guidelines

## Frequently Asked Questions (FAQ)

### General

1. **What is this project about?**  
   This project aims to [insert project goal/summary here].

2. **How do I get started with this project?**  
   Refer to the [README.md](./README.md) file for step-by-step instructions to set up the project.

### Common Errors and Fixes

### Web
- **Error:**   Image does not load in some places of the app.\
  **Solution:** (temporary) use flutter run --web-renderer=html 
  this is just a temporary fix if you want to quickly preview what the app looks like with the new changes in place in the web browser
  (the flag --web-renderer=html is now deprecated and may not be present in future versions of flutter)

#### iOS
- **Error:**   cocoapods and pod install issues.\
  **Solution:**
  1. Ensure CocoaPods is installed: `sudo gem install cocoapods`.
  2. Run `pod install` inside the iOS directory.

- **Error:** App overlaps with the notification bar.  
  **Solution:**
  1. Modify `SafeAreaView` or update the top margin in your app layout.

#### Android
- **Error:** Gradle build fails due to incompatible Java version.  
  **Solution:**
  1. Ensure Java 17 is installed.
  2. Update `build.gradle` to match the required Java version.

- **Error:** Emulator not found.  
  **Solution:**
  1. Check your Android SDK installation path.
  2. Verify that the `emulator` and `adb` paths are added to your `PATH` variable.

#### macOS
- **Error:** `Error: CocoaPods's specs repository is too out-of-date to satisfy dependencies.To update the CocoaPods specs, run:pod repo update Error: Error running pod install` and running pod repo update does not fix it 
- **Solution:** 
    1. go to macos directory delete Pods folder and Podfile.lock
    2. run `pod install` on root of project
    3. try to run the project using `flutter run` this should start building the macOS project 

- **Error:**  An error occurred when accessing the keychain
- **Solution:** 
  1. you need to install xcode from apple app store 
  2. you may need to register to apple developer account if you dont already have one
  3. follow the video guide 
 <div align="center">
  <video width="800" controls>
    <source src="https://raw.githubusercontent.com/HelloSniperMonkey/Monumento/doc/faq/assets/macos/Timeline%202.mp4" type="video/mp4">
  </video>
</div>
- I would like to thank [Andrea Bizzotto](https://github.com/bizz84/simple_auth_flutter_firebase_ui) for his amazing blog on [Flutter & Firebase Auth on macOS: Resolving Common Issues](https://codewithandrea.com/articles/flutter-firebase-auth-macos/) which helped me solve my own issue with the project
  

## How to Contribute to the FAQ

1. If you encounter an issue and resolve it, consider adding it to this FAQ.
2. To propose a change, edit this file and submit a pull request.
3. Ensure you include:
   - A clear problem description.
   - Steps to reproduce the issue.
   - Your solution or workaround.

## Reporting Issues

If you encounter an issue not covered here:

1. **Check Existing Issues**: Before opening a new issue, search the [Issues page](./issues) to avoid duplicates.
2. **Open a New Issue**: If no existing issue matches:
   - Provide a descriptive title.
   - Include a detailed description, including steps to reproduce, expected behavior, and actual behavior.
   - Specify the environment:
     - Operating System (e.g., macOS, Windows, Linux)
     - Platform (e.g., iOS, Android)
     - Node.js and npm versions (if applicable).
3. **Use Labels**: Add relevant labels like `bug`, `enhancement`, `question`, etc.

