import 'package:flutter/material.dart';

/// 趋势页面
/// Create by zyf
/// Date: 2019/7/15
class TrendPage extends StatefulWidget{

  @override
  _TrendPageState createState() => _TrendPageState();
}


class _TrendPageState extends State<TrendPage> with AutomaticKeepAliveClientMixin {
  int _count = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('当前计数:$_count')),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            setState(() {
              _count++;
            });
          }),
    );
  }
}