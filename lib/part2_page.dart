import 'package:flutter/material.dart';

class Part2Page extends StatefulWidget {
  const Part2Page({super.key});

  @override
  State<Part2Page> createState() => _Part2PageState();
}

class _Part2PageState extends State<Part2Page> with TickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..forward() /*..repeat()*/;

  late final Animation<double> _fullScreenAnimation = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.4, curve: Curves.easeIn),
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.4, 1, curve: Curves.easeIn),
  );

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, -0.5),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.4, 1, curve: Curves.easeIn),
  ));

  late final AnimationController _scaleController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..forward();

  int _repeatCount = 0;
  final int _maxRepeats = 3;

  late final Animation<double> _scaleAnimation =
      Tween<double>(begin: 0.9, end: 1.1).animate(
    CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeIn, //const Interval(5 / 7, 1, curve: Curves.easeIn),
    ),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_repeatCount < _maxRepeats) {
          _scaleController.reverse();
        } else {
          _scaleController.stop();
          // setState(() {
          // _scaleController.value = 1;
          // });
        }
      } else if (status == AnimationStatus.dismissed) {
        if (_repeatCount < _maxRepeats) {
          _repeatCount++;
          _scaleController.forward();
        }
      }
    });

    _scaleController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
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
          Positioned(
            top: 270,
            child: _rowText(),
          ),
          Positioned(
            top: 300,
            left: 0,
            right: 0,
            child: _vote(),
          ),
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
          _heartItem(),
          _heartItem(),
          _heartItem(),
        ],
      ),
    );
  }

  Widget _heartItem() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: const Icon(
        Icons.heart_broken,
        size: 30,
        color: Colors.red,
      ),
    );
  }
}
