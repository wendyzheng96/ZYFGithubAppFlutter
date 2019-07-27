import 'package:flutter/material.dart';

/// 底部按钮
/// Create by zyf
/// Date: 2019/7/27
class BottomActionBar extends StatelessWidget {
  final Color color;
  final FloatingActionButtonLocation fabLocation;
  final NotchedShape shape;
  final List<Widget> rowContents;

  const BottomActionBar(
      {this.color, this.fabLocation, this.shape, this.rowContents});

  static final List<FloatingActionButtonLocation> centerLocations =
      <FloatingActionButtonLocation>[
    FloatingActionButtonLocation.centerDocked,
    FloatingActionButtonLocation.centerFloat,
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: color,
      child: Row(children: rowContents,),
      shape: shape,
    );
  }
}
