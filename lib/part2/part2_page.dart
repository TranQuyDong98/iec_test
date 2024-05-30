import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'custom_tooltip.dart';
import 'heart_model.dart';

class Part2Page extends StatefulWidget {
  const Part2Page({super.key});

  @override
  State<Part2Page> createState() => _Part2PageState();
}

class _Part2PageState extends State<Part2Page> with TickerProviderStateMixin {
  final second = 11;
  final GlobalKey _averageKey = GlobalKey();

  double scale = HEART_SIZE_SMALL / HEART_SIZE_NORMAL;

  int vote = 2;
  int totalVote = 10;

  bool isForward = false;

  bool isDone = false;
  int count = 0;

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
      // enable: false,
      fadedAnimation: CurvedAnimation(
        parent: _controller,
        curve: Interval(4 / second, 5 / second, curve: Curves.easeIn),
      ),
    ),
    HeartModel(
      globalKey: GlobalKey(),
      enable: false,
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

  late final _averageController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  late final Animation<double> _scaleAverageAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.975), weight: 1.0),
    TweenSequenceItem(tween: Tween(begin: 0.975, end: 1), weight: 1.0),
  ]).animate(CurvedAnimation(
    parent: _averageController,
    curve: Curves.easeIn,
  ));

  late final Animation<Color?> _colorAnimation = TweenSequence<Color?>([
    TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.grey.withOpacity(0.2),
          end: Colors.pink.withOpacity(0.4),
        ),
        weight: 1.0),
    TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.pink.withOpacity(0.4),
          end: Colors.grey.withOpacity(0.2),
        ),
        weight: 1.0),
  ]).animate(CurvedAnimation(
    parent: _averageController,
    curve: Curves.easeIn,
  ));

  late final _tooltipController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  late final Animation<Offset> _tooltipAnimation = TweenSequence<Offset>([
    TweenSequenceItem(
      tween: Tween(
        begin: Offset.zero,
        end: const Offset(0, 0.2),
      ),
      weight: 1.0,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ),
      weight: 1.0,
    ),
  ]).animate(CurvedAnimation(parent: _tooltipController, curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var data in _hearts) {
        _iniTranslateAnimations(data);
      }
      setState(() {});
      _controller.addListener(addListener);
    });
  }

  addListener() {
    const start = 8;
    for (var data in _hearts) {
      final index = _hearts.indexOf(data);
      if (index % 2 == 0) {
        if ((_controller.value >= ((start + index + 1) / second) &&
            _controller.value < ((start + index + 2) / second) &&
            !isForward)) {
          isForward = true;
          if (data.enable == true) {
            _averageController.forward(from: 0.0);
            vote++;
            count++;
          }
        }
      } else {
        if ((_controller.value >= ((start + index + 1) / second) &&
            _controller.value < ((start + index + 2) / second) &&
            isForward)) {
          isForward = false;
          if (data.enable == true) {
            _averageController.forward(from: 0.0);
            vote++;
            count++;
          }
        }
      }
    }
    isDone = count ==
        (_hearts.where((element) => element.enable == true).toList()).length;
    _tooltipController.repeat();
    setState(() {});
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
    _controller.removeListener(addListener);
    _controller.dispose();
    _averageController.dispose();
    _tooltipController.dispose();
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
          Positioned(top: 250, child: _rowText()),
          Positioned(top: 315, left: 0, right: 0, child: _progress()),
          Positioned(top: 300, left: 0, right: 0, child: _vote()),
          Positioned(bottom: 40, left: 0, right: 0, child: _bottom()),
        ],
      ),
    );
  }

  Widget _rowText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_fadeText("Intro Page"), _fadeText("Design 4")],
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
        padding: const EdgeInsets.all(32.0),
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
      ),
    );
  }

  // Transform.translate
  Widget _heartItem(HeartModel data) {
    return FadeTransition(
      opacity: data.fadedAnimation,
      child: data.enable == true
          ? ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                children: [
                  heartIcon(enable: false),
                  AnimatedBuilder(
                    animation: _rotateAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateAnimation.value * math.pi,
                        child: data.translateAnimation == null
                            ? heartIcon(
                                key: data.globalKey, enable: data.enable)
                            : ScaleTransition(
                                scale: _scaleWithTranslateAnimation,
                                child: AnimatedBuilder(
                                  animation: data.translateAnimation!,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                        data.translateAnimation!.value.dx /
                                            scale,
                                        data.translateAnimation!.value.dy /
                                            scale,
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: heartIcon(
                                      key: data.globalKey, enable: data.enable),
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            )
          : heartIcon(enable: false),
    );
  }

  Widget heartIcon({Key? key, double? size, bool? enable = true}) {
    return Icon(
      key: key,
      Icons.heart_broken,
      size: size ?? HEART_SIZE_NORMAL,
      color: Colors.red.withOpacity(enable == true ? 1.0 : 0.4),
    );
  }

  Widget _average() {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAverageAnimation,
          child: Container(
            width: MediaQuery.sizeOf(context).width - 32 * 2,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
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
          ),
        );
      },
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
            Text(
              '$vote/$totalVote',
              style: const TextStyle(fontSize: 10),
            )
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: vote.toDouble()),
            duration: const Duration(seconds: 1),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value / totalVote,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _progress() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 1),
          opacity: isDone ? 1 : 0,
          curve: Curves.easeIn,
          child: AnimatedSlide(
            duration: const Duration(seconds: 1),
            curve: Curves.easeIn,
            offset: isDone ? const Offset(0, -2) : const Offset(0, 0),
            child: const Text(
              'Fantastic Progress!',
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottom() {
    return AnimatedOpacity(
      duration: const Duration(seconds: 1),
      opacity: isDone ? 1 : 0,
      curve: Curves.easeIn,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _tooltip(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Redesign'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tooltip() {
    return SlideTransition(
      position: _tooltipAnimation,
      child: AnimatedOpacity(
        duration: const Duration(seconds: 2),
        opacity: isDone ? 1 : 0,
        curve: Curves.easeIn,
        child: CustomPaint(
          painter: TooltipPainter(),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text(
              'Can you perfect your design?',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

const double HEART_SIZE_NORMAL = 40.0;
const double HEART_SIZE_SMALL = 16.0;
