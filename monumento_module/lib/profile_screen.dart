import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monumento/login_screen.dart';

class UserProfilePage extends StatefulWidget {
  final FirebaseUser user;
  final DocumentSnapshot profileSnapshot;
  final List<DocumentSnapshot> bookmarkedMonuments;

  UserProfilePage({this.user, this.profileSnapshot, this.bookmarkedMonuments});
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final String _fullName = "Jaideep Prasad";
  final String _status = "Software Developer";
  final String _bio =
      "\"Hi, I am a vagabond and love to visit different monuments.\"";
  final _key = GlobalKey<ScaffoldState>();

  Widget _buildCoverImage(Size screenSize, BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: screenSize.height / 2.6,
          color: Colors.amber,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Text(
                'Monumento',
                style: TextStyle(
                  fontSize: 28.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 140.0,
        height: 140.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: widget.profileSnapshot.data['prof_pic'] != ''?
            NetworkImage(widget.profileSnapshot.data['prof_pic'])
            :
            AssetImage('assets/explore.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(80.0),
          border: Border.all(
            color: Colors.white,
            width: 10.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFullName() {
    TextStyle _nameTextStyle = TextStyle(
//      fontFamily: GoogleFonts.averageSans().fontFamily,
      color: Colors.black,
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
    );

    return Text(
      widget.profileSnapshot.data["name"]??"Monumento User", //_fullName
      style: _nameTextStyle,
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        widget.profileSnapshot.data["status"] == ''?'Monumento-nian':
        widget.profileSnapshot.data["status"],
        style: TextStyle(
          fontFamily: 'Spectral',
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    TextStyle _statLabelTextStyle = TextStyle(
//      fontFamily: GoogleFonts.averageSans().fontFamily,
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.w200,
    );

    TextStyle _statCountTextStyle = TextStyle(
      color: Colors.amber,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count,
          style: _statCountTextStyle,
        ),
        Text(
          label,
          style: _statLabelTextStyle,
        ),
      ],
    );
  }

  Widget _buildStatContainer() {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text('Bookmarks: ',
            style: TextStyle(
                color: Colors.black,
                fontSize: 22.0
            ),
          ),
          Text(widget.bookmarkedMonuments.length.toString(),
            style: TextStyle(
                color: Colors.amber,
                fontSize: 24.0,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBio(BuildContext context) {
    TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w400,//try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      fontSize: 16.0,
    );

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(8.0),
      child: Text(
        _bio,
        textAlign: TextAlign.center,
        style: bioTextStyle,
      ),
    );
  }

  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.6,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }

  Widget _buildGetInTouch(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(top: 8.0),
      child: Text(
        "Last Visited:",
        style: TextStyle(
//            fontFamily: GoogleFonts.averageSans().fontFamily,
            fontSize: 16.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _key,
      body: Stack(
        children: <Widget>[
          _buildCoverImage(screenSize, context),
          (widget.profileSnapshot == null || widget.profileSnapshot.data == null)?
          Center(
            child: Container(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ):
    SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: screenSize.height / 6.4),
                  _buildProfileImage(),
                  _buildFullName(),
                  _buildStatus(context),
                  _buildStatContainer(),
                  _buildBio(context),
                  _buildSeparator(screenSize),
                  SizedBox(height: 8.0),
                  widget.bookmarkedMonuments.length != 0?
                  _buildGetInTouch(context):SizedBox.shrink(),
                  SizedBox(height: 4.0),
                  widget.bookmarkedMonuments.length > 0?
                  ListTile(
                    title: Text(widget.bookmarkedMonuments[0].data['name']),
                    leading: Icon(Icons.account_balance, color: Colors.amber,),
                    dense: true,
                  ):SizedBox.shrink(),
                  widget.bookmarkedMonuments.length > 1?
                  ListTile(
                    title: Text(widget.bookmarkedMonuments[1].data['name']),
                    leading: Icon(Icons.account_balance, color: Colors.amber,),
                    dense: true,
                  ):SizedBox.shrink(),
                  MaterialButton(
                    color: Colors.red,
                    padding: EdgeInsets.all(4.0),
                    child: Text('Log Out', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                    onPressed: () async{
                      _key.currentState.showSnackBar(SnackBar(
                        backgroundColor: Colors.amber,
                        content: Text('Logging Out!',
                          style: TextStyle(color: Colors.white),
                        ),
                      ));
                      await FirebaseAuth.instance.signOut().whenComplete(() {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => LoginScreen())
                        );
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


