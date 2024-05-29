import 'package:flutter/material.dart';

class DrawAction {
  final String key;
  bool disable;
  final Widget icon;
  final void Function()? onPressed;

  DrawAction({
    required this.key,
    this.disable = true,
    required this.icon,
    required this.onPressed,
  });
}
