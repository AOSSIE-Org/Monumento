import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monumento/ui/screens/bookmark/bookmark_screen.dart';
import 'package:monumento/ui/screens/comments/comments_screen.dart';
import 'package:monumento/ui/screens/explore_monuments/explore_screen.dart';
import 'package:monumento/ui/screens/home/home_screen.dart';
import 'package:monumento/ui/screens/login/login_screen.dart';
import 'package:monumento/ui/screens/monument_detail/detail_screen.dart';
import 'package:monumento/ui/screens/new_post/new_post_screen.dart';
import 'package:monumento/ui/screens/notifications/notification_screen.dart';
import 'package:monumento/ui/screens/profile/profile_screen.dart';
import 'package:monumento/ui/screens/profile_form/profile_form_screen.dart';
import 'package:monumento/ui/screens/signup/register_screen.dart';

import 'arguments.dart';

class RouteGenerator {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == ProfileScreen.route) {
      ProfileScreenArguments args =
          settings.arguments as ProfileScreenArguments;
      return MaterialPageRoute(builder: (context) {
        return ProfileScreen(user: args.user);
      });
    }
    if (settings.name == SignUpScreen.route) {
      return MaterialPageRoute(builder: (context) {
        return SignUpScreen();
      });
    }
    if (settings.name == LoginScreen.route) {
      return MaterialPageRoute(builder: (context) {
        return LoginScreen();
      });
    }

    if (settings.name == NewPostScreen.route) {
      NewPostScreenArguments args =
          settings.arguments as NewPostScreenArguments;
      return MaterialPageRoute(builder: (context) {
        return NewPostScreen(
          pickedImage: args.pickedImage,
        );
      });
    }

    if (settings.name == CommentsScreen.route) {
      CommentsScreenArguments args =
          settings.arguments as CommentsScreenArguments;
      return MaterialPageRoute(builder: (context) {
        return CommentsScreen(
          postDocumentRef: args.postDocumentRef,
        );
      });
    }
    if (settings.name == DetailScreen.route) {
      DetailScreenArguments args = settings.arguments as DetailScreenArguments;
      return MaterialPageRoute(builder: (context) {
        return DetailScreen(
          user: args.user,
          monument: args.monument,
          isBookMarked: args.isBookmarked,
        );
      });
    }
    if (settings.name == NotificationsScreen.route) {
      return MaterialPageRoute(builder: (context) {
        return NotificationsScreen();
      });
    }
    if (settings.name == ProfileFormScreen.route) {
      var args = settings.arguments as ProfileFormScreenArguments;

      return MaterialPageRoute(builder: (context) {
        return ProfileFormScreen(
          email: args.email,
          name: args.name,
          uid: args.uid,
        );
      });
    }
    if (settings.name == BookmarkScreen.route) {
      var args = settings.arguments as BookmarkScreenArguments;

      return MaterialPageRoute(builder: (context) {
        return BookmarkScreen(
          user: args.user,
        );
      });
    }
    if (settings.name == ExploreScreen.route) {
      var args = settings.arguments as ExploreScreenArguments;

      return MaterialPageRoute(builder: (context) {
        return ExploreScreen(
          user: args.user,
          monumentList: args.monumentList,
        );
      });
    }

    if (settings.name == HomeScreen.route) {
      var args = settings.arguments as HomeScreenArguments;

      return MaterialPageRoute(builder: (context) {
        return HomeScreen(
          user: args.user,
          navBarIndex: args.navBarIndex,
        );
      });
    }

    assert(false, "Route ${settings.name} not implemented");
    return null;
  }
}
