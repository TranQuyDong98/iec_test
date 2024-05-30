import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'heart_model.dart';

class Part2Page extends StatefulWidget {
  const Part2Page({super.key});

  @override
  State<Part2Page> createState() => _Part2PageState();
}

class _Part2PageState extends State<Part2Page> with TickerProviderStateMixin {
  final second = 11;
  late final _controller = AnimationController(
    vsync: this,
    duration: Duration(seconds: second),
  )..forward() /*..repeat()*/;

  late final Animation<double> _fullScreenAnimation = CurvedAnimation(
    parent: _controller,
    curve: Interval(0, 2 / second, curve: Curves.easeIn),
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Interval(2 / second, 5 / second, curve: Curves.easeIn),
  );

  late final List<HeartModel> _hearts = [
    HeartModel(
      globalKey: GlobalKey(),
      fadedAnimation: CurvedAnimation(
        parent: _controller,
        curve: Interval(3 / second, 4 / second, curve: Curves.easeIn),
      ),
    ),
    HeartModel(
      globalKey: GlobalKey(),
      fadedAnimation: CurvedAnimation(
        parent: _controller,
        curve: Interval(4 / second, 5 / second, curve: Curves.easeIn),
      ),
    ),
    HeartModel(
      globalKey: GlobalKey(),
      fadedAnimation: CurvedAnimation(
        parent: _controller,
        curve: Interval(2 / second, 3 / second, curve: Curves.easeIn),
      ),
    ),
  ];

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, -1),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Interval(2 / second, 5 / second, curve: Curves.easeIn),
  ));

  late final Animation<double> _scaleAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 1.0),
    TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.8), weight: 1.0),
    TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 1.0),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 1.0),
    TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 4.0),
    // TweenSequenceItem(tween: Tween(begin: 1, end: scale), weight: 2.0),
  ]).animate(CurvedAnimation(
    parent: _controller,
    curve: Interval(5 / second, 8 / second, curve: Curves.easeIn),
  ));

  late final Animation<double> _scaleWithTranslateAnimation =
      Tween<double>(begin: 1, end: scale).animate(CurvedAnimation(
    parent: _controller,
    curve: Interval(8 / second, 9 / second, curve: Curves.easeIn),
  ));

  late final Animation<double> _rotateAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -0.1), weight: 1),
    TweenSequenceItem(tween: Tween<double>(begin: -0.1, end: 0.0), weight: 1),
  ]).animate(CurvedAnimation(
    parent: _controller,
    curve: Interval(7 / second, 9 / second, curve: Curves.easeIn),
  ));

  final GlobalKey _averageKey = GlobalKey();

  double scale = HEART_SIZE_SMALL / HEART_SIZE_NORMAL;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var data in _hearts) {
        _iniTranslateAnimations(data);
      }
      setState(() {});
    });
  }

  _iniTranslateAnimations(HeartModel data) {
    final startOffset = _getWidgetOffset(data.globalKey);
    final endOffset = _getWidgetOffset(_averageKey);
    final index = _hearts.indexOf(data);
    if (startOffset != null && endOffset != null) {
      final translateAnimation = Tween<Offset>(
        begin: const Offset(0, 0),
        end: Offset(
          (endOffset.dx -
              startOffset.dx -
              (HEART_SIZE_NORMAL - HEART_SIZE_SMALL) / 2),
          (endOffset.dy -
              startOffset.dy -
              (HEART_SIZE_NORMAL - HEART_SIZE_SMALL) / 2),
        ),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval((8 + index) / second, (8 + index + 1) / second,
            curve: Curves.easeIn),
      ));
      data.translateAnimation = translateAnimation;
    }
  }

  Offset? _getWidgetOffset(GlobalKey? key) {
    final RenderBox? renderBox =
        key?.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return FadeTransition(
      opacity: _fullScreenAnimation,
      child: Stack(
        children: [
          SizedBox.expand(child: Container()),
          SizedBox(
            height: 300,
            width: double.maxFinite,
            child: Image.network(
              'https://picsum.photos/250?image=9',
              fit: BoxFit.fill,
            ),
          ),
          Positioned(top: 270, child: _rowText()),
          Positioned(top: 300, left: 0, right: 0, child: _vote()),
        ],
      ),
    );
  }

  Widget _rowText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [_fadeText("Faded Text1"), _fadeText("Faded Text2")],
      ),
    );
  }

  Widget _fadeText(String text) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _animation,
        child: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _vote() {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        padding: const EdgeInsets.all(32.0).copyWith(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _heart(),
            const SizedBox(height: 24),
            _average(),
          ],
        ),
      ),
    );
  }

  Widget _heart() {
    return Container(
      height: 60,
      width: MediaQuery.sizeOf(context).width - 32 * 2,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_hearts.length, (index) {
          return _heartItem(_hearts[index]);
        }),
        // children: [
        //   // _heartItem(),
        //   // _heartItem(),
        //   _heartItem(key: _hearKey),
        // ],
      ),
    );
  }

  // Transform.translate
  Widget _heartItem(HeartModel data) {
    return FadeTransition(
      opacity: data.fadedAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          children: [
            heartIcon(),
            AnimatedBuilder(
              animation: _rotateAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnimation.value * math.pi,
                  child: data.translateAnimation == null
                      ? heartIcon(key: data.globalKey)
                      : ScaleTransition(
                          scale: _scaleWithTranslateAnimation,
                          child: AnimatedBuilder(
                            animation: data.translateAnimation!,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  data.translateAnimation!.value.dx / scale,
                                  data.translateAnimation!.value.dy / scale,
                                ),
                                child: child,
                              );
                            },
                            child: heartIcon(key: data.globalKey),
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget heartIcon({Key? key, double? size}) {
    return Icon(
      key: key,
      Icons.heart_broken,
      size: size ?? HEART_SIZE_NORMAL,
      color: Colors.red,
    );
  }

  Widget _average() {
    return Container(
      width: MediaQuery.sizeOf(context).width - 32 * 2,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _leftAverage()),
          const SizedBox(width: 12),
          const FlutterLogo(size: 30)
        ],
      ),
    );
  }

  Widget _leftAverage() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'NEXT MILESTONE',
                style: TextStyle(fontSize: 10),
              ),
            ),
            heartIcon(key: _averageKey, size: HEART_SIZE_SMALL),
            const SizedBox(width: 4),
            const Text(
              '2/10',
              style: TextStyle(fontSize: 10),
            )
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.maxFinite,
          color: Colors.red,
          height: 10,
        )
      ],
    );
  }
}

const double HEART_SIZE_NORMAL = 40.0;
const double HEART_SIZE_SMALL = 16.0;
