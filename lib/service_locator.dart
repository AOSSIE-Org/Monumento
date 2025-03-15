import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:monumento/application/popular_monuments/monument_3d_model/monument_3d_model_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_checkin/monument_checkin_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_details/monument_details_bloc.dart';
import 'package:monumento/application/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/application/profile/follow/follow_bloc.dart';
import 'package:monumento/application/profile/profile_posts/profile_posts_bloc.dart';
import 'package:monumento/application/profile/update_profile/update_profile_bloc.dart';
import 'package:monumento/data/repositories/appwrite_authentication_repository.dart';
import 'package:monumento/data/repositories/appwrite_social_repository.dart';
import 'package:monumento/data/repositories/firebase_monument_repository.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';
import 'package:monumento/domain/repositories/monument_repository.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

import 'application/popular_monuments/nearby_places/nearby_places_bloc.dart';
import 'data/repositories/appwrite_monument_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register repositories
  locator
    // Appwrite related
    ..registerLazySingleton(() => Client()
      ..setEndpoint(
          dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1')
      ..setProject(dotenv.env['APPWRITE_PROJECT_ID']))
    ..registerLazySingleton(() => Databases(locator<Client>()))
    ..registerLazySingleton(() => Storage(locator<Client>()))
    ..registerLazySingleton<Account>(
      () => Account(
        locator<Client>(),
      ),
    )
    ..registerLazySingleton<AuthenticationRepository>(
      () => AppwriteAuthenticationRepository(
        account: locator<Account>(),
        database: locator<Databases>(),
      ),
    )
    ..registerLazySingleton<MonumentRepository>(
        instanceName: 'appwriteMonumentRepository',
        () => AppwriteMonumentRepository(
              authenticationRepository: locator<AuthenticationRepository>(),
              database: locator<Databases>(),
            ))
    ..registerLazySingleton<SocialRepository>(() => AppwriteSocialRepository(
        authenticationRepository: locator<AuthenticationRepository>(),
        database: locator<Databases>(),
        storage: locator<Storage>()))
    // Firebase related

    // Register repositories
    ..registerLazySingleton<MonumentRepository>(
      () => FirebaseMonumentRepository(locator<AuthenticationRepository>()),
    )

    // Register blocs
    ..registerLazySingleton(() =>
        AuthenticationBloc(locator<AuthenticationRepository>())
          ..add(AppStarted()))
    ..registerLazySingleton(() => LoginRegisterBloc(
          locator<AuthenticationRepository>(),
          locator<SocialRepository>(),
          locator<AuthenticationBloc>(),
        ))
    ..registerLazySingleton(
      () => PopularMonumentsBloc(locator<MonumentRepository>()),
    )
    ..registerLazySingleton(
      () => MonumentDetailsBloc(locator<MonumentRepository>()),
    )
    ..registerLazySingleton(
      () => FeedBloc(locator<SocialRepository>()),
    )
    ..registerLazySingleton(
      () => CommentsBloc(locator<SocialRepository>()),
    )
    ..registerLazySingleton(
      () => RecommendedUsersBloc(locator<SocialRepository>()),
    )
    ..registerLazySingleton(
      () => NewPostBloc(locator<SocialRepository>()),
    )
    ..registerLazySingleton(
      () => FollowBloc(locator<SocialRepository>()),
    )
    ..registerLazySingleton(
      () => ProfilePostsBloc(locator<SocialRepository>()),
    )
    ..registerLazySingleton(
      () => DiscoverPostsBloc(locator<SocialRepository>()),
    )
    ..registerLazySingleton(
      () => SearchBloc(locator<SocialRepository>()),
    )
    ..registerLazySingleton(
      () => DiscoverProfileBloc(locator<SocialRepository>()),
    )
    ..registerLazySingleton(
      () => BookmarkMonumentsBloc(locator<MonumentRepository>()),
    )
    ..registerLazySingleton(
      () => UpdateProfileBloc(
          locator<SocialRepository>(), locator<AuthenticationRepository>()),
    )
    ..registerLazySingleton(
      () => Monument3dModelBloc(locator<MonumentRepository>()),
    )
    ..registerLazySingleton(
      () => NotificationsBloc(locator<SocialRepository>()),
    )
    ..registerLazySingleton(
      () => MonumentCheckinBloc(locator<SocialRepository>()),
    )
    ..registerLazySingleton(
      () => NearbyPlacesBloc(locator<MonumentRepository>()),
    );
}
