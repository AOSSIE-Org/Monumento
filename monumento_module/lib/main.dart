import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monumento/blocs/comments/comments_bloc.dart';
import 'package:monumento/blocs/discover_posts/discover_posts_bloc.dart';
import 'package:monumento/blocs/feed/feed_bloc.dart';
import 'package:monumento/blocs/follow/follow_bloc.dart';
import 'package:monumento/blocs/new_comment/new_comment_bloc.dart';
import 'package:monumento/blocs/new_post/new_post_bloc.dart';
import 'package:monumento/blocs/notifications/notifications_bloc.dart';
import 'package:monumento/blocs/profile_posts/profile_posts_bloc.dart';
import 'package:monumento/blocs/search/search_bloc.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/authentication/authentication_repository.dart';
import 'package:monumento/resources/social/firebase_social_repository.dart';
import 'package:monumento/resources/social/social_repository.dart';
import 'package:monumento/screens/app_intro.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/blocs/bookmarked_monuments/bookmarked_monuments_bloc.dart';
import 'package:monumento/blocs/login_register/login_register_bloc.dart';
import 'package:monumento/blocs/popular_monuments/popular_monuments_bloc.dart';
import 'package:monumento/blocs/profile/profile_bloc.dart';
import 'package:monumento/resources/authentication/firebase_authentication_repository.dart';
import 'package:monumento/resources/monuments/firebase_monument_repository.dart';
import 'package:monumento/screens/bookmark_screen.dart';
import 'package:monumento/screens/comments/comments_screen.dart';
import 'package:monumento/screens/detail_screen.dart';
import 'package:monumento/screens/explore_screen.dart';
import 'package:monumento/screens/feed/feed_screen.dart';
import 'package:monumento/screens/new_post/new_post_screen.dart';
import 'package:monumento/screens/notifications/notification_screen.dart';
import 'package:monumento/screens/profile/profile_screen.dart';
import 'package:monumento/screens/profile_form/profile_form_screen.dart';
import 'package:monumento/simple_bloc_observer.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //TODO : Remove firebase initialization for faster app startup
  await Firebase.initializeApp();
  Bloc.observer = SimpleBlocObserver();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthenticationRepository _authRepository =
  FirebaseAuthenticationRepository();
  final FirebaseMonumentRepository _monumentRepository =
  FirebaseMonumentRepository();
  final SocialRepository _socialRepository = FirebaseSocialRepository();
  AuthenticationBloc _authenticationBloc;
  LoginRegisterBloc _loginRegisterBloc;
  ProfileBloc _profileBloc;
  BookmarkedMonumentsBloc _bookmarkedMonumentsBloc;
  PopularMonumentsBloc _popularMonumentsBloc;
  NewPostBloc _newPostBloc;
  SearchBloc _searchBloc;
  DiscoverPostsBloc _discoverPostsBloc;
  FeedBloc _feedBloc;
  ProfilePostsBloc _profilePostsBloc;
  NewCommentBloc _newCommentBloc;
  CommentsBloc _commentsBloc;
  FollowBloc _followBloc;
  NotificationsBloc _notificationsBloc;



  @override
  void initState() {
    super.initState();
    _authenticationBloc =
        AuthenticationBloc(authenticationRepository: _authRepository);
    _loginRegisterBloc = LoginRegisterBloc(
        authenticationRepository: _authRepository,
        authenticationBloc: _authenticationBloc, socialRepository: _socialRepository);
    _profileBloc = ProfileBloc(firebaseMonumentRepository: _monumentRepository);
    _bookmarkedMonumentsBloc = BookmarkedMonumentsBloc(
        firebaseMonumentRepository: _monumentRepository);
    _popularMonumentsBloc =
        PopularMonumentsBloc(firebaseMonumentRepository: _monumentRepository);
    _newPostBloc = NewPostBloc(socialRepository: _socialRepository);
    _searchBloc = SearchBloc(socialRepository: _socialRepository);
    _discoverPostsBloc = DiscoverPostsBloc(socialRepository: _socialRepository);
    _feedBloc = FeedBloc(socialRepository: _socialRepository);
    _profilePostsBloc = ProfilePostsBloc(socialRepository: _socialRepository);
    _notificationsBloc = NotificationsBloc(socialRepository: _socialRepository);

    _newCommentBloc = NewCommentBloc(socialRepository: _socialRepository);
    _commentsBloc = CommentsBloc(socialRepository: _socialRepository);
    _followBloc = FollowBloc(socialRepository: _socialRepository);

    _popularMonumentsBloc.add(GetPopularMonuments());
    _authenticationBloc.add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (_) => _authenticationBloc,
        ),
        BlocProvider<LoginRegisterBloc>(
          create: (_) => _loginRegisterBloc,
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => _profileBloc,
        ),
        BlocProvider<PopularMonumentsBloc>(
          create: (_) => _popularMonumentsBloc,
        ),
        BlocProvider<BookmarkedMonumentsBloc>(
          create: (_) => _bookmarkedMonumentsBloc,
        ),

        BlocProvider<NewPostBloc>(
          create: (_) => _newPostBloc,
        ),
        BlocProvider<SearchBloc>(
          create: (_) => _searchBloc,
        ),
        BlocProvider<DiscoverPostsBloc>(
          create: (_) => _discoverPostsBloc,
        ),
        BlocProvider<FeedBloc>(
          create: (_) => _feedBloc,
        ),
        BlocProvider<ProfilePostsBloc>(
          create: (_) => _profilePostsBloc,
        ),
        BlocProvider<CommentsBloc>(
          create: (_) => _commentsBloc,
        ),
        BlocProvider<NewCommentBloc>(
          create: (_) => _newCommentBloc,
        ),
        BlocProvider<FollowBloc>(
          create: (_) => _followBloc,
        ),
        BlocProvider<NotificationsBloc>(
          create: (_) => _notificationsBloc,
        ),

      ],
      child: MultiRepositoryProvider(
  providers: [RepositoryProvider(create: (_)=>_authRepository,),RepositoryProvider(create: (_)=>_socialRepository,)],
  child: MaterialApp(
        title: 'Monumento',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
            primarySwatch: Colors.amber,
            fontFamily: GoogleFonts.montserrat().fontFamily),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (BuildContext context, AuthenticationState state) {
              if (state is Authenticated) {
                return HomeScreen(
                  user: state.user,
                );
                // return Scaffold(body: FeedScreen());
              } else if (state is Unauthenticated) {
                return AppIntroPage();
              }
              return Scaffold(
                backgroundColor: Colors.white,
              );
            }),
        onGenerateRoute: (settings){
          if(settings.name == ProfileScreen.route){
            ProfileScreenArguments args = settings.arguments as ProfileScreenArguments;
            return MaterialPageRoute(builder: (context){
              return ProfileScreen(user:args.user);
            });
          }

          if(settings.name == NewPostScreen.route){
            NewPostScreenArguments args = settings.arguments as NewPostScreenArguments;
            return MaterialPageRoute(builder: (context){
              return NewPostScreen(pickedImage: args.pickedImage,);
            });
          }

          if(settings.name == CommentsScreen.route){
            CommentsScreenArguments args = settings.arguments as CommentsScreenArguments;
            print(args.postDocumentRef.id+"printt");
            return MaterialPageRoute(builder: (context){
              return CommentsScreen(postDocumentRef: args.postDocumentRef,);
            });
          }
          if(settings.name == DetailScreen.route){
            DetailScreenArguments args = settings.arguments as DetailScreenArguments;
            return MaterialPageRoute(builder: (context){
              return DetailScreen(user: args.user,monument: args.monument,isBookMarked: args.isBookmarked,);
            });
          }
          if(settings.name == NotificationsScreen.route){
            return MaterialPageRoute(builder: (context){
              return NotificationsScreen();
            });
          }
          if(settings.name == ProfileFormScreen.route){
            var args = settings.arguments as ProfileFormScreenArguments;

            return MaterialPageRoute(builder: (context){
              return ProfileFormScreen(email: args.email, name: args.name, uid: args.uid,);
            });
          }
          if(settings.name == BookmarkScreen.route){
            var args = settings.arguments as BookmarkScreenArguments;

            return MaterialPageRoute(builder: (context){
              return BookmarkScreen(user: args.user,);
            });
          }
          if(settings.name == ExploreScreen.route){
            var args = settings.arguments as ExploreScreenArguments;

            return MaterialPageRoute(builder: (context){
              return ExploreScreen(user: args.user,monumentList: args.monumentList,);
            });
          }

          if(settings.name == HomeScreen.route){
            var args = settings.arguments as HomeScreenArguments;

            return MaterialPageRoute(builder: (context){
              return HomeScreen(user: args.user,navBarIndex: args.navBarIndex,);
            });
          }

          assert(false,"Route ${settings.name} not implemented");
          return null;
        },
      ),
),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _bookmarkedMonumentsBloc.close();
    _popularMonumentsBloc.close();
    _profileBloc.close();
    _loginRegisterBloc.close();
    _authenticationBloc.close();
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Text(
          'Welcome to Monumento!',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(
          Icons.home,
          color: Colors.white,
        ),
      ),
    );
  }
}
