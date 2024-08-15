import 'package:get_it/get_it.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/application/discover/discover_posts/discover_posts_bloc.dart';
import 'package:monumento/application/discover/discover_profile/discover_profile_bloc.dart';
import 'package:monumento/application/discover/search/search_bloc.dart';
import 'package:monumento/application/feed/comments/comments_bloc.dart';
import 'package:monumento/application/feed/feed_bloc.dart';
import 'package:monumento/application/feed/new_post/new_post_bloc.dart';
import 'package:monumento/application/feed/recommended_users/recommended_users_bloc.dart';
import 'package:monumento/application/notifications/notifications_bloc.dart';
import 'package:monumento/application/popular_monuments/bookmark_monuments/bookmark_monuments_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_checkin/monument_checkin_bloc.dart';
import 'package:monumento/application/profile/follow/follow_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_details/monument_details_bloc.dart';
import 'package:monumento/application/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/application/profile/profile_posts/profile_posts_bloc.dart';
import 'package:monumento/application/profile/update_profile/update_profile_bloc.dart';
import 'package:monumento/data/repositories/firebase_monument_repository.dart';
import 'package:monumento/data/repositories/firebase_social_repository.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';
import 'package:monumento/domain/repositories/monument_repository.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

import 'data/repositories/firebase_authentication_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register repositories
  locator.registerLazySingleton<AuthenticationRepository>(
      () => FirebaseAuthenticationRepository());
  locator.registerLazySingleton<SocialRepository>(() =>
      FirebaseSocialRepository(
          authenticationRepository: locator<AuthenticationRepository>()));
  locator.registerLazySingleton<MonumentRepository>(
      () => FirebaseMonumentRepository(locator<AuthenticationRepository>()));

  // Register blocs
  locator.registerLazySingleton(() =>
      AuthenticationBloc(locator<AuthenticationRepository>())
        ..add(AppStarted()));
  locator.registerLazySingleton(() => LoginRegisterBloc(
      locator<AuthenticationRepository>(),
      locator<SocialRepository>(),
      locator<AuthenticationBloc>()));
  locator.registerLazySingleton(
      () => PopularMonumentsBloc(locator<MonumentRepository>()));
  locator.registerLazySingleton(
      () => MonumentDetailsBloc(locator<MonumentRepository>()));
  locator.registerLazySingleton(() => FeedBloc(locator<SocialRepository>()));
  locator
      .registerLazySingleton(() => CommentsBloc(locator<SocialRepository>()));
  locator.registerLazySingleton(
      () => RecommendedUsersBloc(locator<SocialRepository>()));
  locator.registerLazySingleton(() => NewPostBloc(locator<SocialRepository>()));

  locator.registerLazySingleton(() => FollowBloc(locator<SocialRepository>()));

  locator.registerLazySingleton(() => ProfilePostsBloc(
        locator<SocialRepository>(),
      ));
  locator.registerLazySingleton(
      () => DiscoverPostsBloc(locator<SocialRepository>()));
  locator.registerLazySingleton(() => SearchBloc(locator<SocialRepository>()));
  locator.registerLazySingleton(
      () => DiscoverProfileBloc(locator<SocialRepository>()));
  locator.registerLazySingleton(
      () => BookmarkMonumentsBloc(locator<MonumentRepository>()));
  locator.registerLazySingleton(() => UpdateProfileBloc(
      locator<SocialRepository>(), locator<AuthenticationRepository>()));
  locator.registerLazySingleton(
      () => NotificationsBloc(locator<SocialRepository>()));
  locator.registerLazySingleton(
      () => MonumentCheckinBloc(locator<SocialRepository>()));
}
