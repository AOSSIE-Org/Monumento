import 'package:flutter/material.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:monumento/ui/screens/login/login_screen.dart';

class AppIntroPage extends StatefulWidget {
  @override
  _AppIntroPageState createState() => _AppIntroPageState();
}

class _AppIntroPageState extends State<AppIntroPage> {
  final introPages = [
    PageViewModel(
        title: Text('EXPLORE'),
        titleTextStyle: TextStyle(
            color: Colors.amber, fontSize: 24.0, fontWeight: FontWeight.w700),
        body: Text('Travel around the world and visit different monuments'),
        bodyTextStyle: TextStyle(color: Colors.amber),
        mainImage: Container(
          margin: EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  image: AssetImage('assets/explore.jpg'), fit: BoxFit.cover)),
        ),
        bubbleBackgroundColor: Colors.amber),
    PageViewModel(
        title: Text('KNOW'),
        titleTextStyle: TextStyle(
            color: Colors.amber, fontSize: 24.0, fontWeight: FontWeight.w700),
        body: Text(
            'Know all about the monuments visited by you and people around the world'),
        bodyTextStyle: TextStyle(color: Colors.amber),
        mainImage: Container(
          margin: EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  image: AssetImage('assets/know.png'), fit: BoxFit.cover)),
        ),
        bubbleBackgroundColor: Colors.amber),
    PageViewModel(
        title: Text('VISUALIZE'),
        titleTextStyle: TextStyle(
            color: Colors.amber, fontSize: 24.0, fontWeight: FontWeight.w700),
        body: Text(
            'Check out what the monuments actually look like up close in Augmented Reality'),
        bodyTextStyle: TextStyle(color: Colors.amber),
        mainImage: Container(
          margin: EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.grey[100],
              image: DecorationImage(
                  image: AssetImage('assets/ar_image.jpg'), fit: BoxFit.cover)),
        ),
        bubbleBackgroundColor: Colors.amber),
  ];

  void onClose() {
    Navigator.of(context).pushReplacement(new PageRouteBuilder(
        maintainState: true,
        opaque: true,
        pageBuilder: (context, _, __) => LoginScreen(),
        transitionDuration: const Duration(seconds: 2),
        transitionsBuilder: (context, anim1, anim2, child) {
          return new FadeTransition(
            child: child,
            opacity: anim1,
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => IntroViewsFlutter(
          introPages,
          background: Colors.white,
          onTapDoneButton: () => onClose(),
          pageButtonTextStyles: TextStyle(
            color: Colors.amber,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}
