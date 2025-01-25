import 'package:flutter/material.dart';

class GenericAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final double elevation;
  final Widget logo; // Accept logo as a widget
  final IconData icon; // Accept the icon
  final VoidCallback onPressed; // Accept the onPressed callback

  const GenericAppBar({
    Key? key,
    this.height = kToolbarHeight,
    this.elevation = 4,
    required this.logo,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: elevation,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo passed from the parent widget
          logo,
          IconButton(
            onPressed: onPressed, // Trigger the provided onPressed callback
            icon: Icon(
              icon, // Use the provided icon
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
