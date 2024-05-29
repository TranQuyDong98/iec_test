import 'dart:math' as math;

import 'package:flutter/material.dart';

class Part2Page extends StatefulWidget {
  const Part2Page({super.key});

  @override
  State<Part2Page> createState() => _Part2PageState();
}

class _Part2PageState extends State<Part2Page> with TickerProviderStateMixin {
  final second = 9;
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

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, -0.5),
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
    TweenSequenceItem(tween: Tween(begin: 1, end: scale), weight: 2.0),
  ]).animate(CurvedAnimation(
    parent: _controller,
    curve: Interval(5 / second, 9 / second, curve: Curves.easeIn),
  ));

  late final Animation<double> _rotateAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -0.1), weight: 1),
    TweenSequenceItem(tween: Tween<double>(begin: -0.1, end: 0.0), weight: 1),
  ]).animate(CurvedAnimation(
    parent: _controller,
    curve: Interval(7 / second, 9 / second, curve: Curves.easeIn),
  ));

  Animation<Offset>? _translateAnimation;

  final GlobalKey _hearKey = GlobalKey();
  final GlobalKey _averageKey = GlobalKey();
  Offset? _offsetA;
  Offset? _offsetB;

  double scale = HEART_SIZE_SMALL / HEART_SIZE_NORMOL;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _offsetA = _getWidgetOffset(_hearKey);
      _offsetB = _getWidgetOffset(_averageKey);
      if (_offsetA != null && _offsetB != null) {
        _translateAnimation = Tween<Offset>(
          begin: const Offset(0, 0),
          end: Offset(
            (_offsetB!.dx -
                _offsetA!.dx -
                (HEART_SIZE_NORMOL - HEART_SIZE_SMALL) / 2),
            (_offsetB!.dy -
                _offsetA!.dy -
                (HEART_SIZE_NORMOL - HEART_SIZE_SMALL) / 2),
          ),
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(
            8 / second,
            9 / second,
            curve: Curves.easeIn,
          ),
        ));
        setState(() {});
      }
    });
  }

  // Function to get the offset of a widget using its global key
  Offset? _getWidgetOffset(GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
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
        children: [
          // _heartItem(),
          // _heartItem(),
          _heartItem(key: _hearKey),
        ],
      ),
    );
  }

  // Transform.translate
  Widget _heartItem({Key? key}) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _rotateAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotateAnimation.value * math.pi,
            child: _translateAnimation == null
                ? heartIcon(key: key)
                : AnimatedBuilder(
                    animation: _translateAnimation!,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          _translateAnimation!.value.dx / scale,
                          _translateAnimation!.value.dy / scale,
                        ),
                        child: child,
                      );
                    },
                    child: heartIcon(key: key),
                  ),
            // child: heartIcon(key: key),
          );
        },
      ),
    );
  }

  Widget heartIcon({Key? key, double? size}) {
    return Icon(
      key: key,
      Icons.heart_broken,
      size: size ?? HEART_SIZE_NORMOL,
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

const double HEART_SIZE_NORMOL = 40.0;
const double HEART_SIZE_SMALL = 16.0;
