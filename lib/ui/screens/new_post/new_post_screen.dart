import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/blocs/feed/feed_bloc.dart';
import 'package:monumento/blocs/new_post/new_post_bloc.dart';
import 'package:monumento/navigation/arguments.dart';
import 'package:monumento/resources/social/social_repository.dart';
import 'package:monumento/ui/screens/home/home_screen.dart';

class NewPostScreen extends StatefulWidget {
  static final String route = "/newPostScreen";
  final File pickedImage;
  NewPostScreen({@required this.pickedImage});
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  NewPostBloc _newPostBloc;
  FeedBloc _feedBloc;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _newPostBloc = NewPostBloc(
        socialRepository: RepositoryProvider.of<SocialRepository>(context));
    _feedBloc = BlocProvider.of<FeedBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewPostBloc, NewPostState>(
        bloc: _newPostBloc,
        listener: (context, state) {
          if (state is NewPostAdded) {
            print("new post added" + state.post.imageUrl);
            //TODO : Change navigation pattern
            AuthenticationBloc authBloc =
                BlocProvider.of<AuthenticationBloc>(context, listen: false);

            _feedBloc.add(LoadInitialFeed());
            Navigator.pushNamedAndRemoveUntil(
                context, HomeScreen.route, (route) => false,
                arguments: HomeScreenArguments(
                    user: (authBloc.state as Authenticated).user,
                    navBarIndex: 1));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("New Post"),
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          persistentFooterButtons: [
            TextButton(
                onPressed: () {
                  _newPostBloc.add(AddNewPost(
                      image: widget.pickedImage,
                      location: _locationController.text,
                      title: _titleController.text));
                },
                child: Text("Post"))
          ],
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.file(widget.pickedImage,
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width),
                      ),
                      Divider(
                        height: 24,
                        thickness: 2,
                      ),
                      Text("Title"),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(hintText: "Add a title"),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text("Location"),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(hintText: "Add a location"),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<NewPostBloc, NewPostState>(
                  bloc: _newPostBloc,
                  builder: (context, state) {
                    return state is AddingNewPost
                        ? Positioned.fill(
                            child: Center(
                            child: CircularProgressIndicator(),
                          ))
                        : Container();
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
