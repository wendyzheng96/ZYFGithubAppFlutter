import 'package:json_annotation/json_annotation.dart';

/// 提交统计
/// Create by zyf
/// Date: 2019/8/5
part 'CommitStats.g.dart';

@JsonSerializable()
class CommitStats  {
  int total;
  int additions;
  int deletions;

  CommitStats(this.total, this.additions, this.deletions);

  factory CommitStats.fromJson(Map<String, dynamic> json) => _$CommitStatsFromJson(json);

  Map<String, dynamic> toJson() => _$CommitStatsToJson(this);
}