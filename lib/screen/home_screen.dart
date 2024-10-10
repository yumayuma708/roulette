import 'dart:math';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _currentAngle = 0.0;
  final int _numOfSegments = 8;
  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    final double randomAngle = _getRandomAngle();
    _animation = Tween<double>(
      begin: _currentAngle,
      end: _currentAngle + randomAngle,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _currentAngle = _animation.value % (2 * pi);
          _animationController.reset();
          _showResult();
        }
      });
  }

  double _getRandomAngle() {
    final random = Random();
    const double rotations = 5;
    final double randomStop = random.nextDouble() * 2 * pi;
    return rotations * 2 * pi + randomStop;
  }

  void _spinRoulette() {
    if (!_animationController.isAnimating) {
      _animation = Tween<double>(
        begin: _currentAngle,
        end: _currentAngle + _getRandomAngle(),
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ),
      )
        ..addListener(() {
          setState(() {});
        })
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _currentAngle = _animation.value % (2 * pi);
            _animationController.reset();
            _showResult();
          }
        });

      _animationController.forward();
    }
  }

  void _showResult() {
    // 停止したセグメントを計算
    double angle = _currentAngle % (2 * pi);
    double segmentAngle = 2 * pi / _numOfSegments;
    int index =
        (_numOfSegments - (angle / segmentAngle).floor()) % _numOfSegments;
    String result = 'Result: Segment ${index + 1}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ルーレットの結果'),
          content: Text(result),
          actions: [
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildRouletteWheel() {
    return Transform.rotate(
      angle: _animation.value,
      child: CustomPaint(
        size: const Size(300, 300),
        painter: RoulettePainter(
          numOfSegments: _numOfSegments,
          colors: _colors,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーレットアプリ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildRouletteWheel(),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _spinRoulette,
              child: const Text('まわす'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoulettePainter extends CustomPainter {
  final int numOfSegments;
  final List<Color> colors;

  RoulettePainter({required this.numOfSegments, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    double angle = 2 * pi / numOfSegments;
    double radius = size.width / 2;
    Offset center = Offset(radius, radius);

    var paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < numOfSegments; i++) {
      paint.color = colors[i % colors.length];
      double startAngle = i * angle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        angle,
        true,
        paint,
      );
    }

    // 描画の中心にポインターを追加
    paint.color = Colors.black;
    Path path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx - 10, center.dy - radius + 20);
    path.lineTo(center.dx + 10, center.dy - radius + 20);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(RoulettePainter oldDelegate) {
    return false;
  }
}
