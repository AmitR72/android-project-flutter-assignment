import 'package:flutter/material.dart';



Future<bool> showSnackBar({required BuildContext context, String text = ""}) async {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text)));
  return Future<bool>.value(false);
}