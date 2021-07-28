import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key key, @required this.title, @required this.textStyle}) : super(key: key);
  final String title;
  final TextStyle textStyle;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: Row(children: [
      Text(title,style: textStyle,),Spacer(),IconButton(onPressed: (){}, icon: Icon(Icons.notifications_active_outlined))
    ],),);
  }
}
