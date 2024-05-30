import 'dart:ui';

import 'package:uuid/uuid.dart';

class Sticker {
  final Offset? localOffset;
  final String id;

  Sticker({this.localOffset, String? id}) : id = id ?? const Uuid().v4();

  Sticker copyWith({Offset? localOffset}) {
    return Sticker(
      localOffset: localOffset ?? this.localOffset,
      id: id,
    );
  }
}
