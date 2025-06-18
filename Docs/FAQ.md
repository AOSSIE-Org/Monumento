# 📋 FAQ and Issue Reporting Guidelines

## ❓ Frequently Asked Questions (FAQ)

### 🌟 General

1. **What is Monumento?**  
   Monumento is an AR-integrated social app that transforms how you connect with the world's most iconic landmarks. It allows you to check in to popular monuments, explore famous sites, and engage with a community of travelers and history enthusiasts.

2. **How do I get started with this project?**  
   Refer to the [setup guide](./setup.md) for step-by-step instructions to set up the project with Appwrite backend.

### 🔧 Common Errors and Fixes

### 🌐 Web Platform

- **Error:** Images do not load in some places of the app.  
  **Solution:** Use `flutter run -d chrome --web-renderer html` to run the app. This is a temporary fix to preview the app in a web browser.

- **Error:** Google Sign-In does not work on web.  
  **Solution:** Ensure your Appwrite OAuth settings and Google Cloud console settings are correctly configured with matching redirect URIs and origins.

### 🍏 iOS Platform

- **Error:** CocoaPods and pod install issues.  
  **Solution:**
  1. Ensure CocoaPods is installed: `sudo gem install cocoapods`.
  2. Run `pod install` inside the iOS directory.

- **Error:** App overlaps with the notification bar.  
  **Solution:** Modify `SafeAreaView` or update the top margin in your app layout.

### 🤖 Android Platform

- **Error:** Gradle build fails due to incompatible Java version.  
  **Solution:**
  1. Ensure Java 17 is installed.
  2. Update `build.gradle` to match the required Java version.

- **Error:** Emulator not found.  
  **Solution:**
  1. Check your Android SDK installation path.
  2. Verify that the `emulator` and `adb` paths are added to your `PATH` variable.

### 🍎 macOS Platform

- **Error:** `Error: CocoaPods's specs repository is too out-of-date to satisfy dependencies.`  
  **Solution:** 
  1. Go to macOS directory, delete Pods folder and Podfile.lock
  2. Run `pod install` on root of project
  3. Try to run the project using `flutter run`

- **Error:** An error occurred when accessing the keychain  
  **Solution:** 
  1. Install Xcode from Apple App Store
  2. You may need to register for an Apple Developer account
  3. Follow the video guide: [Keychain Access Guide](https://github.com/user-attachments/assets/c3b408cf-aabd-4bf3-9866-32b4982c463c)

### ☁️ Appwrite Specific Issues

- **Error:** Unable to connect to Appwrite services.  
  **Solution:** Verify your Appwrite endpoint and project ID in the `.env` file.

- **Error:** Authentication issues with Appwrite.  
  **Solution:** Make sure OAuth providers are properly configured in the Appwrite console.

- **Error:** "Document not found" errors when accessing collections.  
  **Solution:** Run the setup script again to ensure all collections and documents are created.

- **Error:** Appwrite storage permission issues.  
  **Solution:** Check that your API key has proper permissions for database and storage operations.

## 🤝 How to Contribute to the FAQ

1. If you encounter an issue and resolve it, consider adding it to this FAQ.
2. To propose a change, edit this file and submit a pull request.
3. Ensure you include:
   - A clear problem description.
   - Steps to reproduce the issue.
   - Your solution or workaround.

## 📝 Reporting Issues

If you encounter an issue not covered here:

1. **Check Existing Issues**: Before opening a new issue, search the [Issues page](https://github.com/AOSSIE-Org/Monumento/issues) to avoid duplicates.
2. **Open a New Issue**: If no existing issue matches:
   - Provide a descriptive title.
   - Include a detailed description, including steps to reproduce, expected behavior, and actual behavior.
   - Specify the environment:
     - Operating System (e.g., macOS, Windows, Linux)
     - Platform (e.g., iOS, Android, Web)
     - Flutter, Dart and Node.js versions (if applicable)
3. **Use Labels**: Add relevant labels like `bug`, `enhancement`, `question`, etc.

## 📣 Community Support

If you need additional help, join our [Discord community](https://discord.gg/6mFZ2S846n) where fellow developers can assist with your questions.

