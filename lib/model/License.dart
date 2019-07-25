import 'package:json_annotation/json_annotation.dart';

/// 协议
/// Create by zyf
/// Date: 2019/7/24

part 'License.g.dart';

@JsonSerializable()
class License {

  String name;

  License(this.name);

  factory License.fromJson(Map<String, dynamic> json) => _$LicenseFromJson(json);

  Map<String, dynamic> toJson() => _$LicenseToJson(this);
}