import 'package:github_app_flutter/model/CommitFile.dart';
import 'package:github_app_flutter/model/CommitGitInfo.dart';
import 'package:github_app_flutter/model/CommitStats.dart';
import 'package:github_app_flutter/model/RepoCommit.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:json_annotation/json_annotation.dart';

/// 提交详情
/// Create by zyf
/// Date: 2019/8/5
part 'PushCommit.g.dart';

@JsonSerializable()
class PushCommit {
  List<CommitFile> files;

  CommitStats stats;

  String sha;
  String url;
  @JsonKey(name: "html_url")
  String htmlUrl;
  @JsonKey(name: "comments_url")
  String commentsUrl;

  CommitGitInfo commit;
  User author;
  User committer;
  List<RepoCommit> parents;

  PushCommit(
      this.files,
      this.stats,
      this.sha,
      this.url,
      this.htmlUrl,
      this.commentsUrl,
      this.commit,
      this.author,
      this.committer,
      this.parents,
      );

  factory PushCommit.fromJson(Map<String, dynamic> json) => _$PushCommitFromJson(json);

  Map<String, dynamic> toJson() => _$PushCommitToJson(this);
}
