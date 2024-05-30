import 'package:flutter/cupertino.dart';

class HeartModel {
  final Animation<double> fadedAnimation;
  Animation<Offset>? translateAnimation;
  final GlobalKey? globalKey;

  HeartModel({
    required this.fadedAnimation,
    this.globalKey,
    this.translateAnimation,
  });
}
