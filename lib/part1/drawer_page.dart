import 'package:flutter/material.dart';

import 'action.dart';
import 'draw_painter.dart';

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

  @override
  void initState() {
    super.initState();
    initActions();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Draw Page'),
        actions: [
          IconButton(
            onPressed: _onUndo,
            icon: const Icon(Icons.undo),
            color: Colors.black,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _customPaint()),
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
    ..color = erase ? Colors.white : Colors.teal
    ..strokeWidth = erase ? 15 : 10
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  Widget _customPaint() {
    return GestureDetector(
      onPanStart: (details) {
        var initPath = Path()
          ..moveTo(details.localPosition.dx, details.localPosition.dy);
        paths.add(initPath);
        final paint = initPaint();
        mapPathPaints.add(MapEntry<Path, Paint>(initPath, paint));
        setState(() {});
      },
      onPanUpdate: (details) {
        final lastPath = paths.last;
        lastPath.lineTo(details.localPosition.dx, details.localPosition.dy);
        final last = mapPathPaints.last.key;
        last.lineTo(details.localPosition.dx, details.localPosition.dy);
        setState(() {});
      },
      onPanEnd: (details) {},
      child: CustomPaint(
        size: Size.infinite,
        painter: DrawPainter(
          paths: paths,
          mapPathPaints: mapPathPaints,
        ),
      ),
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
}
