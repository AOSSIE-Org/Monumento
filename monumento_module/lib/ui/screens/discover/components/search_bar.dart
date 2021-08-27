import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final FocusNode node;
  final Function onChange;
  final TextEditingController controller;

  const SearchBar({@required this.node, this.onChange, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChange,
      focusNode: node,
      controller: controller,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey, width: 2)),
          hintText: "Search People",
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          prefixIcon: Icon(Icons.search_outlined)),
    );
  }
}
