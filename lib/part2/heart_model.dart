import 'package:flutter/cupertino.dart';

class HeartModel {
  final Animation<double> fadedAnimation;
  final Animation<double> rotateAnimation;
  final Animation<double> scaleAnimation;
  Animation<Offset>? translateAnimation;
  final GlobalKey? globalKey;
  final bool? enable;

  HeartModel({
    required this.fadedAnimation,
    required this.rotateAnimation,
    required this.scaleAnimation,
    this.globalKey,
    this.translateAnimation,
    this.enable = true,
  });
}
