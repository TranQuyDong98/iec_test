import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;

import 'action.dart';
import 'draw_painter.dart';
import 'sticker_model.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  List<Path> paths = <Path>[];
  List<MapEntry<Path, Paint>> mapPathPaints = [];
  bool erase = false;

  late List<DrawAction> actions = [];

  bool hide = false;
  List<Sticker> stickers = <Sticker>[];

  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initActions();
  }

  Offset convertGlobalToLocalOffset(BuildContext context, Offset global) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localOffset = renderBox.globalToLocal(global);
    return localOffset;
  }

  initActions() {
    actions.addAll(
      [
        DrawAction(
          key: 'draw',
          icon: const Icon(Icons.edit),
          onPressed: onDraw,
          disable: false,
        ),
        DrawAction(
          key: 'erase',
          icon: const Icon(Icons.cleaning_services),
          onPressed: _onEraser,
        )
      ],
    );
  }

  onDraw() {
    setState(() {
      erase = false;
    });
  }

  _onEraser() {
    setState(() {
      erase = true;
    });
  }

  _onUndo() {
    if (mapPathPaints.isNotEmpty) {
      mapPathPaints.removeLast();
      setState(() {});
    }
  }

  void onPanStart(DragStartDetails details) {
    var initPath = Path()
      ..moveTo(details.localPosition.dx, details.localPosition.dy);
    paths.add(initPath);
    final paint = initPaint();
    mapPathPaints.add(MapEntry<Path, Paint>(initPath, paint));
    setState(() {});
  }

  void onPanUpdate(DragUpdateDetails details) {
    final lastPath = paths.last;
    lastPath.lineTo(details.localPosition.dx, details.localPosition.dy);
    final last = mapPathPaints.last.key;
    last.lineTo(details.localPosition.dx, details.localPosition.dy);
    setState(() {});
  }

  Future<Uint8List?> takeScreenShot() async {
    final boundary = _globalKey.currentContext?.findRenderObject();
    if (boundary is RenderRepaintBoundary) {
      ui.Image image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio * 1.5,
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes?.buffer
          .asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    }
    return null;
  }

  onSaver() async {
    Uint8List? bytes = await takeScreenShot();
    if (bytes != null) {
      final result = await ImageGallerySaver.saveImage(
        bytes,
        name: "draw_${DateTime.now().millisecondsSinceEpoch}",
      );
      if (result != null) {
        _showDialog();
      }
    }
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Image Save Success!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Draw Page'),
        actions: [
          IconButton(
            onPressed: onSaver,
            icon: const Icon(Icons.save),
            color: Colors.black,
          ),
          IconButton(
            onPressed: _onUndo,
            icon: const Icon(Icons.undo),
            color: Colors.black,
          ),
        ],
      ),
      body: Column(
        children: [
          _draggable(),
          const SizedBox(height: 40),
          Expanded(child: _customPaint()),
          const SizedBox(height: 40),
          Container(
            height: 50,
            width: double.maxFinite,
            color: Colors.blue,
            child: _bottom(),
          )
        ],
      ),
    );
  }

  Paint initPaint() => Paint()
    ..color = erase ? Colors.grey[300]! : Colors.teal
    ..strokeWidth = erase ? 15 : 10
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  Widget _customPaint() {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: MediaQuery.sizeOf(context).width - 32,
        height: double.maxFinite,
        alignment: Alignment.center,
        color: Colors.grey[300],
        child: GestureDetector(
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          child: Builder(builder: (context) {
            return DragTarget<Sticker>(
              onAcceptWithDetails: (details) {
                Offset localOffset =
                    convertGlobalToLocalOffset(context, details.offset);
                if (stickers.isEmpty) {
                  stickers.add(details.data.copyWith(localOffset: localOffset));
                } else {
                  stickers
                      .removeWhere((element) => element.id == details.data.id);
                  stickers.add(details.data.copyWith(localOffset: localOffset));
                }
                setState(() {
                  hide = true;
                });
              },
              builder: (context, candidateData, rejectedData) => _drawBlock(),
            );
          }),
        ),
      ),
    );
  }

  Widget _drawBlock() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRect(
          child: CustomPaint(
            size: Size.infinite,
            painter: DrawPainter(
              paths: paths,
              mapPathPaints: mapPathPaints,
            ),
          ),
        ),
        if (stickers.isNotEmpty)
          ...List.generate(stickers.length, (index) {
            final sticker = stickers[index];
            final offset = sticker.localOffset;
            return Positioned(
              left: offset?.dx,
              top: offset?.dy,
              child: _draggable(data: sticker),
            );
          }),
      ],
    );
  }

  Widget _bottom() {
    return Row(
      children: List.generate(
        actions.length,
        (index) => Expanded(
          child: _bottomAction(
            onPressed: () {
              actions[index].onPressed?.call();
              for (int i = 0; i < actions.length; i++) {
                actions[i].disable = !(i == index);
              }
              setState(() {});
            },
            action: actions[index],
            showDivider: index != actions.length - 1,
            disable: actions[index].disable,
          ),
        ),
      ),
    );
  }

  Widget _bottomAction({
    final void Function()? onPressed,
    required DrawAction action,
    bool showDivider = true,
    bool disable = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: !showDivider
            ? null
            : const Border(
                right: BorderSide(color: Colors.white),
              ),
      ),
      alignment: Alignment.center,
      child: IconButton(
        onPressed: onPressed,
        icon: action.icon,
        color: disable ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _draggable({Sticker? data}) {
    return Draggable<Sticker>(
      data: data ?? Sticker(),
      feedback: _buildSticker(),
      childWhenDragging: _buildSticker(opacity: data == null ? 1 : 0),
      child: _buildSticker(),
    );
  }

  Widget _buildSticker({double opacity = 1.0}) {
    return Opacity(
        opacity: opacity,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: FlutterLogo(),
        ));
  }
}
