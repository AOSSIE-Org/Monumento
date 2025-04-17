# 🏛️ Setup Guide for Monumento

This guide will walk you through setting up the Monumento app with Appwrite backend services.

## 🚀 Step 1) Project Setup

### 📥 Clone the project

```bash
git clone https://github.com/AOSSIE-Org/Monumento.git
```

### 📁 Navigate to the project directory

```bash
cd Monumento
```

### 📦 Install Flutter dependencies

```bash
flutter pub get
```

### 🔑 Create environment file

Create `.env` file using the template:

```bash
cat .env.template > .env
```

## ☁️ Step 2) Configure Appwrite

### 1. 🔐 Create an Appwrite Account and Project

- Sign up at [Appwrite Cloud](https://cloud.appwrite.io) or set up a self-hosted instance
- Create a new project (note your **Project ID**)
- Add a Flutter platform under "Platforms" in your project settings
  - For Web: Enter your website domain
  - For Android/iOS: Enter your application ID

### 2. 🗝️ Create API Key

- Go to "API Keys" under Project Settings
- Create a new API key with the following permissions:
  - Database (all)
  - Storage (all)

### 3. 🛠️ Run Setup Script

The project includes a script to set up all required Appwrite resources:

```bash
cd lib/scripts
npm install node-appwrite
node setup_appwrite.js
```

Follow the prompts to enter your:
- Appwrite API key
- Project ID

This script will automatically create:
- 📊 Database and collections
- 🖼️ Storage bucket for images
- 🗿 Sample monument data
- appwrite function for forget passwords 

**Note**: After creating the Appwrite function for password reset, there's an additional step required to make the "Forgot Password" functionality work properly.

You need to register the domain where the password reset will be triggered. To do this:

1. Go to your Appwrite Console.

2. Navigate to your project Overview.

3. Scroll down and click “Add Platform”.

4. Choose Web App.

5. In the domain field, enter your app’s domain (make sure to remove the https:// prefix and any trailing /).
   
6. Add the link to the function in your .env file 

Once your domain is added and registered, the "Forgot Password" feature will work correctly.
If this step is skipped, you may encounter an error like:
Invalid URL: must be appwrite.io or *.appwrite.io.

### 4. ⚙️ Configure Environment Variables

Fill in the following values in your `.env` file:

```
GEOAPIFY_API_KEY=            # From Geoapify.com for location services
APPWRITE_DATABASE_ID=dbmonumento
APPWRITE_USER_ID=users
APPWRITE_POSTS_ID=posts
APPWRITE_MONUMENTS_ID=monuments
APPWRITE_COMMENTS_ID=comments
APPWRITE_LIKES_ID=postLikes
APPWRITE_CHECKIN_ID=checkIn
APPWRITE_LOCALEXPERTS_COLLECTION_ID=localExperts
APPWRITE_API_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_BUCKET_ID=bucketmonumento
APPWRITE_PROJECT_ID=         # Your Appwrite Project ID
```

## 🔐 Step 3) Configure Google Sign-In 

### 1. 📝 Create OAuth Credentials

- Go to the [Google Cloud Console](https://console.cloud.google.com/)
- Create a new project or use an existing one
- Navigate to "APIs & Services" > "Credentials"
- Create OAuth 2.0 Client IDs for each platform (Web, Android, iOS)
- Enable the **Google People API** in the API Library

### 2. 🌐 Add Authorized Domains (for Web)

- For web sign-in, add your domain to "Authorized JavaScript origins"
- For local testing, you can use `http://localhost`

### 3. 🔄 Configure Redirect URIs

In your Appwrite Console:
- Go to Project Settings > Authentication
- Under OAuth providers, enable and configure Google
- Add your OAuth Client ID and Secret
- Configure redirect URLs properly

## 🗺️ Step 4) Configure Geoapify API

1. 📝 Sign up for an account at [Geoapify](https://www.geoapify.com/)
2. 🔑 Create an API key
3. ➕ Add the API key to your `.env` file as `GEOAPIFY_API_KEY`

## 🏃‍♂️ Running the Application

Now you're ready to run the application:

```bash
flutter run
```

## ❓ Troubleshooting

If you encounter any issues during setup or running the app, please refer to the [FAQ](./FAQ.md) for common problems and solutions.

For platform-specific issues:
- 🌐 **Web**: Use `flutter run -d chrome --web-renderer html` if images don't load correctly
- 🍎 **iOS/macOS**: See the FAQ section for CocoaPods and keychain access issues
- 🤖 **Android**: Ensure you've added the proper configurations

## 📚 Additional Resources

- [Appwrite Documentation](https://appwrite.io/docs) 📄
- [Flutter Documentation](https://docs.flutter.dev) 💙
- [Geoapify Documentation](https://apidocs.geoapify.com/) 🗺️
