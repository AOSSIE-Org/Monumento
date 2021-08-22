
# Monumento

## Student - Suryansh Singh Tomar
## Links
- Project : https://gitlab.com/aossie/monumento
- Working Demo : https://drive.google.com/file/d/1aU6B8xHfNAvyZBJTXg8S3ckUSHrYb4VJ/view?usp=sharing
## Monumento


The goal of this year's project was

- To plan and execute the migration of pre-existing codebase to BLoC (Business Logic and Components) Architecture and State management pattern.
- To design and implement UI/UX, Database Model and Business logic for a Social Media Platform for Travellers section.
- To make the app compatible with iOS by writing native swift code and using Flutter's methods channels.


### Work done


1. New UI/UX of Home Screen
2. Implementation of Feed Screen where a user can view posts of users they follow
3. Implementation of Comments Screen of a post
4. Implementation of Notifications Screen of a user
5. Implementation of New Post Screen with the option to input title, location, and image from gallery/camera
6. Implementation of Discover Screen for exploring global posts
7. Implementation of Follow Unfollow Business Logic and UI
8. Implementation of Profile Screen
9. Implementation of Profile Form when signing in for the first time
10. Replaced deprecated Poly links of 3d model with new Firebase Storage Links
11. Implementation of Models, Entities, and Repositories
12. Implementation of BLoC architecture and separate UI, logic and data layer.
13. Implementation of lazy - loading on scroll for the lists in Feed, Search, Comment, Profile and Discover screens.
14. Data fed and structured in Firestore as the database for app
15. Replaced deprecated poly links with firebase storage links

Initially, the project ideas were only to add a Social Media section in the app and to make the app compatible with iOS, but I also saw the need to refactor the code into a scalable and maintainable architecture. Therefore, I proposed the idea to migrate the codebase to BLoC architecture as well. Implementing BLoC architecture is not as punishing as it was before the release of [flutter_bloc](https://pub.dev/packages/flutter_bloc) package.


The most crucial part of implementing the Social Media section was planning and designing the Database Model according to the queries I was going to use. After that, I didn't encounter many problems implementing the section.


### Deep view into the technology.


I mainly worked on the Flutter module of the Native Android app. I kept the use of packages to a minimum to eliminate the dependencies of the app.

* [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Widgets that make it easy to integrate blocs and cubits into [Flutter](https://flutter.dev/)
* [equatable](https://pub.dev/packages/equatable) - Used to compare objects in dart
* [alamofire](https://github.com/Alamofire/Alamofire) - Used for networking in swift


### Prominent Merge Requests
1. [ Merge request !67](https://gitlab.com/aossie/monumento/-/merge_requests/67) -  Migrated the app to BLoC architecture - Status: *Merged*

2. [Merge request !69](https://gitlab.com/aossie/monumento/-/merge_requests/69) -  Added Models and Entities - Status: *Merged*

3. [Merge request !70](https://gitlab.com/aossie/monumento/-/merge_requests/70) - Implement NewPostScreen, and create Social Repository and Models - Status: *Merged*


4. [Merge request !71](https://gitlab.com/aossie/monumento/-/merge_requests/71) - Implement Feed Screen and BLoCs - Status: *Merged*


5. [Merge request !72](https://gitlab.com/aossie/monumento/-/merge_requests/72) - Implement Discover Screen and BLoCs - Status: *Merged*

6. [Merge request !73](https://gitlab.com/aossie/monumento/-/merge_requests/73) - Implement Profile Screen and BLoCs - Status: *Merged*

7. [Merge request !74](https://gitlab.com/aossie/monumento/-/merge_requests/74) - Implement Comments Screen and BLoCs - Status: *Merged*


8.  [Merge request !75](https://gitlab.com/aossie/monumento/-/merge_requests/75) - Implement Monumento Screen and Follow-Unfollow BLoC - Status: *Merged*
9. [Merge request !76](https://gitlab.com/aossie/monumento/-/merge_requests/76) - Implement Notification Screen and BLoCs - Status: *Merged*
10. [Merge request !77](https://gitlab.com/aossie/monumento/-/merge_requests/77) - Improve Auth Flow - Status: *Merged*
11. [Merge request !78](https://gitlab.com/aossie/monumento/-/merge_requests/78) - Navigation and UI Completed - Status: *Merged*
12. [Merge request !79](https://gitlab.com/aossie/monumento/-/merge_requests/79) - Final Touches and Code Refactoring - Status: *Merged*
13. [Merge request !80](https://gitlab.com/aossie/monumento/-/merge_requests/80) - Replaced Poly Links with Firebase Storage links
14. [Merge request !61](https://gitlab.com/aossie/monumento/-/merge_requests/61) - iOS implementation - Status: *Open*

### Future Possible Work
- Refactor the code to get dynamic monuments model data from the database
- Push notifications using FCM or any other service


I want to thank the AOSSIE community and my very supportive mentors, Jaideep Prasad, Thuvarakan Tharmarajasingam, and Tushar Kumar Singh. Being a part of this incredible community feels great. I have learnt a lot in these past 3-4 months and would continue contributing as much as I can.