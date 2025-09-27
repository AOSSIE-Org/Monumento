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
import 'package:monumento/application/popular_monuments/ai_chat_bot/ai_chat_bot_bloc.dart';
import 'package:monumento/application/popular_monuments/bookmark_monuments/bookmark_monuments_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_3d_model/monument_3d_model_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_checkin/monument_checkin_bloc.dart';
import 'package:monumento/application/popular_monuments/monument_details/monument_details_bloc.dart';
import 'package:monumento/application/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/application/profile/follow/follow_bloc.dart';
import 'package:monumento/application/profile/profile_posts/profile_posts_bloc.dart';
import 'package:monumento/application/profile/update_profile/update_profile_bloc.dart';
import 'package:monumento/data/repositories/ai_chat_repository_impl.dart';
import 'package:monumento/data/repositories/appwrite_authentication_repository.dart';
import 'package:monumento/data/repositories/appwrite_social_repository.dart';
import 'package:monumento/domain/repositories/ai_chat_repository.dart';
import 'package:monumento/domain/repositories/authentication_repository.dart';
import 'package:monumento/domain/repositories/monument_repository.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

import 'application/popular_monuments/nearby_places/nearby_places_bloc.dart';
import 'data/repositories/appwrite_monument_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Services
  setupAppServices();

  // Repositories
  setupAppRepos();

  // Blocs
  setupAppBlocs();
}

void setupAppServices() {
  final client = Client()
    ..setEndpoint(
        dotenv.env['APPWRITE_API_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1')
    ..setProject(dotenv.env['APPWRITE_PROJECT_ID']);

  locator.registerLazySingleton(() => client);
  locator.registerLazySingleton(() => Databases(locator<Client>()));
  locator.registerLazySingleton(() => Storage(locator<Client>()));
  locator.registerLazySingleton(() => Account(locator<Client>()));
}

void setupAppRepos() {
  locator.registerLazySingleton<AuthenticationRepository>(
    () => AppwriteAuthenticationRepository(
      account: locator<Account>(),
      database: locator<Databases>(),
    ),
  );

  locator.registerLazySingleton<MonumentRepository>(
    () => AppwriteMonumentRepository(
      authenticationRepository: locator<AuthenticationRepository>(),
      database: locator<Databases>(),
    ),
  );

  locator
      .registerLazySingleton<SocialRepository>(() => AppwriteSocialRepository(
            authenticationRepository: locator<AuthenticationRepository>(),
            database: locator<Databases>(),
            storage: locator<Storage>(),
          ));
  // AI Chat Repository
  locator.registerLazySingleton<AiChatRepository>(
    () => AiChatRepositoryImpl(),
  );
}

void setupAppBlocs() {
  final authenticationBloc =
      AuthenticationBloc(locator<AuthenticationRepository>());
  authenticationBloc.add(AppStarted());

  locator.registerLazySingleton(() => authenticationBloc);
  locator.registerLazySingleton(() => LoginRegisterBloc(
        locator<AuthenticationRepository>(),
        locator<SocialRepository>(),
        locator<AuthenticationBloc>(),
      ));

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
  locator.registerLazySingleton(
      () => ProfilePostsBloc(locator<SocialRepository>()));
  locator.registerLazySingleton(
      () => DiscoverPostsBloc(locator<SocialRepository>()));
  locator.registerLazySingleton(() => SearchBloc(locator<SocialRepository>()));
  locator.registerLazySingleton(
      () => DiscoverProfileBloc(locator<SocialRepository>()));
  locator.registerLazySingleton(
      () => BookmarkMonumentsBloc(locator<MonumentRepository>()));
  locator.registerLazySingleton(() => UpdateProfileBloc(
        locator<SocialRepository>(),
        locator<AuthenticationRepository>(),
      ));
  locator.registerLazySingleton(
      () => Monument3dModelBloc(locator<MonumentRepository>()));
  locator.registerLazySingleton(
      () => NotificationsBloc(locator<SocialRepository>()));
  locator.registerLazySingleton(
      () => MonumentCheckinBloc(locator<SocialRepository>()));
  locator.registerLazySingleton(
      () => NearbyPlacesBloc(locator<MonumentRepository>()));
  // AI Chat Bloc
  locator.registerFactory<AiChatBloc>(
    () => AiChatBloc(locator<AiChatRepository>()),
  );
}
