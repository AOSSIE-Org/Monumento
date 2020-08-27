# Monumento

## Student - Jaideep Prasad
## Links  
- Project : https://gitlab.com/aossie/monumento

## Monumento 

The goal of the project is to provide users an unique experience of exploring and learning more about the various monumental structures all around the world within the app. It's core feature involves detecting a monument from its image, letting users know its name and Wikipedia details all from within the app along with visualizing a 3D model of it infront of them. The app having features like Popular Monuments, Bookmarks, Exploring about them all from within the app provides an interesting and knowledgable experience for them.

### Approach towards Development

Initially, I had envisioned the project with Flutter completely for cross-platform support as it suited the project idea. But along my way, working out the details and developing the sample prototype for the project idea, I got to know that ‘Landmark Detection’ from the Firebase Vision API in particular wasn’t yet supported with Flutter. To make it work, I needed to write quite good amount of native code for both Android and iOS platforms. If we were use to use on-device processing, that would make the app itself heavy since we would need to train our own custom ML model with a lot of data as an user can try to detect a monument from any angle possible. All these points, got me to reject the idea of Flutter for the complete app development. But at the same time, Flutter really has some great benefits such as extremely good UX/UI development, smooth performance, faster productive development, multiplatform support for future using same codebase. So I thought why not develop a native Android application and integrate Flutter with it for the frontend work and some backend work binding as well if needed.

### Prominent Feature list 

1. Integrated Firebase and GCP projects with app - **Done**
2. User Authentication, Login Screen, Google Sign-In, Sign-up screen (Registration with Email and password) - **Done** 
3. Custom Intro Welcome screens with Animations, Splash Screen - **Done** 
4. Home Screen, Carousel UI, Animated Bottom Navigation Drawer, Checking for Logged in User and App navigation accordingly - **Done** 
5. Home Screen, Popular Monuments, Explore, Bookmarks  - **Done** 
6. Monument Detector Screen integrated with Cloud Vision API for on cloud processing - **Done** 
7. Data fed and structured in Firestore as database for app - **Done** 
8. Setting up Sceneform SDK with app, Setting up ARCore with app, Developing the ARFragment, Adding static assets/3D models, Rendering models in AR scene - **Done** 
9. Developed online runtime rendering of models from Poly in app - **Done** 
10. Developed Wikipedia feature, Sliding up panel integrated for Wikipedia, Data sharing across Detector and AR screens, Wiki page according to monument in realtime - **Done** 
11. Database integration in Monument Detector and AR Fragment - **Done**
12. Detail Screen for Monuments with Animation - **Done**
13. Wikipedia for Popular Monuments - **Done**
14. Visualize Popular Monuments in AR directly - **Done**
15. Bookmark Monuments, DB/Backend integration for Bookmarks - **Done**
16. Unique User id Authentication logic added for bookmarks collection - **Done**
17. Profile Screen, User details while Sign Up, Log Out feature - **Done**

### Deep view into the technology. 

This project has been developed with [Flutter](https://flutter.dev) and [Android](https://g.co/kgs/VTQxaz) for Native support. It makes use of minimal open source libraries available for Flutter and Android. Some of which are listed below

* [API Client](https://developers.google.com/api-client-library/java) - Provides support for Cloud Vision API from Google Cloud.
* [Sceneform SDK](https://github.com/google-ar/sceneform-android-sdk) - Provides AR support for app, rendering 3D models in app.
* [Material Design](https://material.io) - Provides support for developing material components in native Android.
* [Firebase](https://firebase.google.com) - Provides Authentication Support for app, Firestore as backend/database support.
* [Google Sign-In](https://pub.dev/packages/google_sign_in) - Provides sign in support with Google.
* [Google Fonts](https://pub.dev/packages/google_fonts) - Provides official font support for Flutter apps.
* [Flutter Web View](https://pub.dev/packages/webview_flutter) - Provides Web View support with various configuration options for Flutter SDK.

### Prominent Merge Requests 
1. [ Merge request !14](https://gitlab.com/aossie/monumento/-/merge_requests/14) - User Login, Google Sign-In - Login Screen: - status *Merged*
    * Initialized the project with Firebase, GCP, developed authentication and the intarface screens.

2. [Merge request !16](https://gitlab.com/aossie/monumento/-/merge_requests/16) - App Home Screen, Carousel, Bottom Nav bar - status *Merged*
    * After developing Registration screens, developed the App Home interface.

3. [Merge request !19](https://gitlab.com/aossie/monumento/-/merge_requests/19) - Explore Popular Monuments, Firestore backend/db structured, Linked with Home  - Status: *Merged*
    * After finishing with App Intro and onboarding screens, developed the popular monuments feature with necessary Home screen linkage with Firestore.

4. [Merge request !24](https://gitlab.com/aossie/monumento/-/merge_requests/24) - Upgrades on AR fragment, more models, ux improved, cleanup - Status: *Merged*
    * Implemented AR visualization of 3D models from online host Poly
    * Implemented Monument Detector screen before this.

5. [Merge request !26](https://gitlab.com/aossie/monumento/-/merge_requests/26) - Wikipedia Feature, AR Fragment updates - Status: *Merged*
    * Implemented Wikipedia feature for detected Monuments with AR Fragment updates.

6. [Merge request !28](https://gitlab.com/aossie/monumento/-/merge_requests/28) - Detail page, Animations, Wikipedia for Popular monuments - Status: *Merged*
    * Implemented Detail screen with animations for popular monuments, wikipedia feature for popular monuments.
    * Developed direct AR visualization of popular monuments after this.

7. [Merge request !31](https://gitlab.com/aossie/monumento/-/merge_requests/31) - Bookmark updates, Unique User Auth id for bookmark and more - Status: *Merged*
    * Implemented Bookmark Monument feature, interface for detailed bookmarks, Backend logic and structure for Bookmarks, UX updates.

8. [Merge request !32](https://gitlab.com/aossie/monumento/-/merge_requests/32) - Profile Screen, User details creation while logging and more - Status: *Merged*
    * Implemented Profile Screen intarface, User details while Sign up interface, Log out feature.

I would like to thank the whole AOSSIE community, especially my mentors, Thuvarakan Tharmarajasingam, Mukul Kumar and Alwis for being so nice and helpful. I have learnt a lot in the past 3 months and it has been a great experience to be a part of this wonderful community and develop this awesome project.

