import 'package:flutter/cupertino.dart';

class HeartModel {
  final Animation<double> fadedAnimation;
  final Animation<double> rotateAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double> scaleWithTranslateAnimation;
  Animation<Offset>? translateAnimation;
  final GlobalKey? globalKey;
  final bool? enable;

  HeartModel({
    required this.fadedAnimation,
    required this.rotateAnimation,
    required this.scaleAnimation,
    required this.scaleWithTranslateAnimation,
    this.globalKey,
    this.translateAnimation,
    this.enable = true,
  });
}
