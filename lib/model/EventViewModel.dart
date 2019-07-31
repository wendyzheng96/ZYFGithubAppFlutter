import 'package:github_app_flutter/common/utils/event_utils.dart';
import 'package:github_app_flutter/common/utils/time_utils.dart';
import 'package:github_app_flutter/model/Event.dart';
import 'package:github_app_flutter/model/RepoCommit.dart';

/// 仓库事件信息
/// Create by zyf
/// Date: 2019/7/31
class EventViewModel {
  String actionUser;
  String actionUserPic;
  String actionDes;
  String actionTime;
  String actionTarget;

  EventViewModel(this.actionUser, this.actionUserPic, this.actionDes,
      this.actionTime, this.actionTarget);

  EventViewModel.fromEventMap(Event event) {
    actionTime = formatDate(
        event.createdAt.toLocal(), [yyyy, '/', mm, '/', dd, ' ', HH, ":", nn]);
    actionUser = event.actor.login;
    actionUserPic = event.actor.avatar_url;
    var other = EventUtils.getActionAndDes(event);
    actionDes = other["des"];
    actionTarget = other["actionStr"];
  }

  EventViewModel.fromCommitMap(RepoCommit eventMap) {
    actionUserPic = "";
    actionTime = getTimeAgoStr(eventMap.commit.committer.date);
    actionUser = eventMap.commit.committer.name;
    actionDes = "sha: " + eventMap.sha;
    actionTarget = eventMap.commit.message;
  }
}
