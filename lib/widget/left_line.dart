import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';

/// 侧边进度条线
/// Create by zyf
/// Date: 2019/7/17
class LeftLineWidget extends StatelessWidget {
  final bool showTop;
  final bool showBottom;
  final bool isLight;

  const LeftLineWidget(this.showTop, this.showBottom, this.isLight);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      width: 15,
      child: CustomPaint(
        painter: LeftLinePaint(showTop, showBottom, isLight),
      ),
    );
  }
}

class LeftLinePaint extends CustomPainter {
  static const double _topHeight = 16;
  static const Color _circleColor = Color(0xff9FB6CD);
  static const Color _lineColor = Color(ZColors.lineColor);

  final bool showTop;
  final bool showBottom;
  final bool isLight;

  LeftLinePaint(this.showTop, this.showBottom, this.isLight);

  @override
  void paint(Canvas canvas, Size size) {
    double lineWidth = 1;
    double centerX = size.width / 2;
    double radius = centerX / 2;

    Paint linePaint = Paint();
    linePaint.color = showTop ? _lineColor : Colors.transparent;
    linePaint.strokeWidth = lineWidth;
    linePaint.strokeCap = StrokeCap.square;
    canvas.drawLine(
        Offset(centerX, 0), Offset(centerX, _topHeight - radius), linePaint);

    linePaint.color = showBottom ? _lineColor : Colors.transparent;
    canvas.drawLine(Offset(centerX, _topHeight + radius),
        Offset(centerX, size.height), linePaint);

    Paint circlePaint = Paint();
    circlePaint.color = _circleColor;
    circlePaint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, _topHeight), radius, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
