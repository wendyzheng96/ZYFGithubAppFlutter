import 'package:json_annotation/json_annotation.dart';

/// 趋势页面项目Item
/// Create by zyf
/// Date: 2019/7/18
part 'TrendingRepoModel.g.dart';

@JsonSerializable()
class TrendingRepoModel {
  String fullName;
  String url;

  String description;
  String language;
  String meta;
  List<String> contributors;
  String contributorsUrl;

  String starCount;
  String forkCount;
  String name;

  String reposName;

  TrendingRepoModel(
      this.fullName,
      this.name,
      this.contributors,
      this.contributorsUrl,
      this.reposName,
      this.description,
      this.language,
      this.starCount,
      this.forkCount,
      this.meta,
      this.url,
     );

  TrendingRepoModel.empty();

  factory TrendingRepoModel.fromJson(Map<String, dynamic> json) => _$TrendingRepoModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrendingRepoModelToJson(this);
}