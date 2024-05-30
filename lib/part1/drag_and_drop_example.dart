import 'package:flutter/material.dart';

import 'sticker_model.dart';

class DragAndDropExample extends StatefulWidget {
  const DragAndDropExample({super.key});

  @override
  State<DragAndDropExample> createState() => _DragAndDropExampleState();
}

class _DragAndDropExampleState extends State<DragAndDropExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _body()),
    );
  }

  bool hide = false;
  List<Sticker> stickers = <Sticker>[];

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _draggable(),
        const SizedBox(height: 40),
        Builder(builder: (context) {
          return Container(
            width: 300, //MediaQuery.sizeOf(context).width,
            height: 300, //MediaQuery.sizeOf(context).height,
            color: Colors.grey[300],
            child: DragTarget<Sticker>(
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
              onWillAcceptWithDetails: (details) {
                return true;
              },
              builder: (context, candidateData, rejectedData) {
                if (stickers.isEmpty) return Container();
                return Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(stickers.length, (index) {
                    final sticker = stickers[index];
                    final offset = sticker.localOffset;
                    return Positioned(
                      left: offset?.dx,
                      top: offset?.dy,
                      child: _draggable(data: sticker),
                    );
                  }),
                );
              },
            ),
          );
        })
      ],
    );
  }

  Offset convertGlobalToLocalOffset(BuildContext context, Offset global) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localOffset = renderBox.globalToLocal(global);
    return localOffset;
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
