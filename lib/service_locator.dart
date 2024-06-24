import 'package:get_it/get_it.dart';
import 'package:monumento/application/authentication/authentication_bloc.dart';
import 'package:monumento/application/authentication/login_register/login_register_bloc.dart';
import 'package:monumento/application/feed/comments/comments_bloc.dart';
import 'package:monumento/application/feed/feed_bloc.dart';
import 'package:monumento/application/feed/new_post/new_post_bloc.dart';
import 'package:monumento/application/feed/recommended_users/recommended_users_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_details/monument_details_bloc.dart';
import 'package:monumento/application/popular_monuments/popular_monuments_bloc.dart';
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
      () => FirebaseMonumentRepository());

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
}
