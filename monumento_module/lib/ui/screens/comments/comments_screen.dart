import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:monumento/blocs/authentication/authentication_bloc.dart';
import 'package:monumento/blocs/comments/comments_bloc.dart';
import 'package:monumento/blocs/new_comment/new_comment_bloc.dart';
import 'package:monumento/resources/social/models/comment_model.dart';
import 'package:monumento/resources/social/social_repository.dart';
import 'package:monumento/ui/screens/comments/components/comment_tile.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key key, @required this.postDocumentRef})
      : super(key: key);
  final DocumentReference postDocumentRef;
  static final String route = '/commentsScreen';

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  CommentsBloc _commentsBloc;
  NewCommentBloc _newCommentBloc;
  AuthenticationBloc _authenticationBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _commentsBloc = CommentsBloc(
        socialRepository: RepositoryProvider.of<SocialRepository>(context));
    _newCommentBloc = NewCommentBloc(
        socialRepository: RepositoryProvider.of<SocialRepository>(context));
    _authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context, listen: false);
    _commentsBloc
        .add(LoadInitialComments(postDocReference: widget.postDocumentRef));
  }

  List<CommentModel> comments = [];
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CommentsBloc, CommentsState>(
              bloc: _commentsBloc,
              builder: (context, currentState) {
                if (currentState is InitialCommentsLoadingFailed) {
                  return Center(child: Text(currentState.message));
                }

                if (currentState is InitialCommentsLoaded ||
                    currentState is MoreCommentsLoaded ||
                    currentState is LoadingMoreComments ||
                    currentState is MoreCommentsLoadingFailed) {
                  bool hasReachedMax = false;

                  if (currentState is InitialCommentsLoaded) {
                    hasReachedMax = currentState.hasReachedMax;
                    comments = [];
                    comments.insertAll(
                        comments.length, currentState.initialComments);
                  }
                  if (currentState is MoreCommentsLoaded) {
                    hasReachedMax = currentState.hasReachedMax;
                    comments.insertAll(comments.length, currentState.comments);
                  }
                  if (comments.isEmpty) {
                    return Center(
                      child: Text("No comments"),
                    );
                  }

                  return LazyLoadScrollView(
                    child: ListView.separated(
                      itemCount: comments.length,
                      itemBuilder: (_, index) {
                        if (currentState is LoadingMoreComments &&
                            index == comments.length - 1) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CommentTile(
                                comment: comments[index],
                              ),
                              CircularProgressIndicator(),
                            ],
                          );
                        }
                        return CommentTile(
                          comment: comments[index],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          height: 16,
                          color: Colors.transparent,
                        );
                      },
                    ),
                    onEndOfPage: !hasReachedMax ? _loadMoreComments : () {},
                    scrollOffset: 300,
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          BlocConsumer<NewCommentBloc, NewCommentState>(
            bloc: _newCommentBloc,
            listener: (_, state) {
              if (state is CommentAdded) {
                _commentsBloc.add(LoadInitialComments(
                    postDocReference: widget.postDocumentRef));
                _commentController.clear();
              }
            },
            builder: (context, currentState) {
              return Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, .16), blurRadius: 36)
                  ],
                ),
                child: Row(
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: _authenticationBloc.state is Authenticated
                            ? (_authenticationBloc.state as Authenticated)
                                .user
                                .profilePictureUrl
                            : "",
                        height: 36,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type your comment",
                        ),
                      ),
                    ),
                    ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(200),
                        child: IconButton(
                          icon: Icon(
                            Icons.check,
                            color: currentState is AddingComment
                                ? Colors.grey
                                : Colors.green,
                          ),
                          onPressed: currentState is AddingComment
                              ? () {}
                              : () {
                                  _newCommentBloc.add(AddCommentPressed(
                                      postDocReference: widget.postDocumentRef,
                                      comment: _commentController.text));
                                },
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  _loadMoreComments() {
    _commentsBloc.add(LoadMoreComments(
        startAfterDoc: comments.last.snapshot,
        postDocReference: widget.postDocumentRef));
  }
}
