import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:monumento/domain/entities/user_entity.dart';
import 'package:monumento/utils/constants.dart';

class UserConnectionsTile extends StatefulWidget {
  final List<UserEntity> user;
  const UserConnectionsTile({super.key, required this.user});

  @override
  State<UserConnectionsTile> createState() => _UserConnectionsTileState();
}

class _UserConnectionsTileState extends State<UserConnectionsTile> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.user.length,
      itemBuilder: (context, i) {
        return ListTile(
          leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(widget.user[i].profilePictureUrl ??
                        defaultProfilePicture),
                ),
                title: Text(widget.user[i].name),
                subtitle: Text(widget.user[i].username!),
                trailing: CustomElevatedButton(onPressed: (){}, text: "follow/unfollow"),
        );
      },
    );
  }
}