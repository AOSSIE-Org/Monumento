import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/constants.dart';

showBottom(BuildContext context, dynamic profileSnapshot) async {
  await showModalBottomSheet(
      elevation: 0,
      backgroundColor: Colors.yellow.withOpacity(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      context: context,
      builder: (btcx) {
        return TypeSelector(profileSnapshot);
      });
}

class TypeSelector extends StatefulWidget {
  var profileSnapshot;
  TypeSelector(this.profileSnapshot);
  @override
  _TypeSelectorState createState() => _TypeSelectorState();
}

class _TypeSelectorState extends State<TypeSelector> {
  List<Map<String, dynamic>> icons = [
    {"icon": Icons.delete, "text": "Remove Photo"},
    {
      "icon": Icons.camera,
      "text": "Camera",
    },
    {
      "icon": Icons.image,
      "text": "Image",
    },
  ];

  Future getImage(int i, BuildContext context) async {
    if (i == 0) {
      if (widget.profileSnapshot.data['prof_pic'] != null ||
          widget.profileSnapshot.data['prof_pic'].length >= 2) {
        QuerySnapshot query = await Firestore.instance
            .collection('users')
            .where("auth_id", isEqualTo: widget.profileSnapshot.data['auth_id'])
            .limit(1)
            .getDocuments();
        query.documents[0].reference.updateData({'prof_pic': ""}).then(
            (value) => {print("successfully Updated")});
      }
      return;
    }

    var pickedFile = null;
    if (i == 1)
      pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    else
      pickedFile = await ImagePicker().getVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      File _image = File(pickedFile.path);
      var ref;
      ref = FirebaseStorage.instance
          .ref()
          .child("${widget.profileSnapshot.data['auth_id']}/images")
          .child("${DateTime.now()}.jpg");

      await ref.putFile(_image);

      var dowurl = await ref.getDownloadURL();
      print(dowurl.toString());
      String url = dowurl.toString();
      QuerySnapshot query = await Firestore.instance
          .collection('users')
          .where("auth_id", isEqualTo: widget.profileSnapshot.data['auth_id'])
          .limit(1)
          .getDocuments();
      query.documents[0].reference
          .updateData({'prof_pic': url})
          .then((value) => {print("successfully updated")})
          .catchError((err) => {print(err.toString())});
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          "Please choose Pick a file",
          style: TextStyle(fontFamily: "Roboto"),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(6),
        height: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.white),
        padding: const EdgeInsets.only(top: 13, left: 10, right: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Profile Photo",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            SizedBox(height: 25),
            Container(
              height: 100,
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    childAspectRatio: 3 / 2,
                    maxCrossAxisExtent: 160,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: icons.length,
                  itemBuilder: (_, i) {
                    return InkWell(
                      onTap: () {
                        getImage(i, context);
                      },
                      child: Container(
                        child: Column(
                          children: [
                            CircleAvatar(
                              child: Icon(icons[i]["icon"]),
                            ),
                            FittedBox(
                                child: Text(
                              icons[i]["text"],
                              softWrap: true,
                            ))
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ));
  }
}
