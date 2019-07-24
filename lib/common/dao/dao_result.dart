import 'package:flutter/material.dart';

/// 数据结果
/// Create by zyf
/// Date: 2019/7/23
class DataResult {
  var data;
  bool result;
  Function next;

  DataResult(this.data, this.result, {this.next});
}
