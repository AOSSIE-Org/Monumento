import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/blocs/new_post/new_post_bloc.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  NewPostBloc _newPostBloc;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _newPostBloc = BlocProvider.of<NewPostBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    File pickedImage = ModalRoute.of(context).settings.arguments as File;
    return BlocListener<NewPostBloc, NewPostState>(
        listener: (context, state) {
          if (state is NewPostAdded) {

            print("new post added"+ state.post.imageUrl);
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
                      image: pickedImage,
                      location: _locationController.text,
                      title: _titleController.text));
                },
                child: Text("Post"))
          ],
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.file(pickedImage,
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
                  SizedBox(height: 16,),
                  Text("Location"),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(hintText: "Add a location"),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}