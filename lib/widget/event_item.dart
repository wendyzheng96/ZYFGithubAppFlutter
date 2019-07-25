import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/event_utils.dart';
import 'package:github_app_flutter/model/event.dart';
import 'package:github_app_flutter/widget/left_line.dart';

/// 事件Item
/// Create by zyf
/// Date: 2019/7/17
class EventItem extends StatelessWidget {
  final EventViewModel eventViewModel;

  final VoidCallback onPressed;

  final bool needImage;

  final int index;

  final int count;

  EventItem(this.eventViewModel, this.index, this.count,
      {this.onPressed, this.needImage = true})
      : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 32,
              child: LeftLineWidget(index != 0, index != count - 1, false),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(ZColors.primaryValue),
              backgroundImage: NetworkImage(eventViewModel.actionUserPic),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                eventViewModel.actionUser,
                style: TextStyle(
                    color: Color(ZColors.textPrimaryValue), fontSize: 14),
              ),
            ),
            Expanded(
                child: Container(
              padding: EdgeInsets.only(right: 16),
              alignment: Alignment.bottomRight,
              child: Text(
                eventViewModel.actionTime,
                style: TextStyle(
                    color: Color(ZColors.textHintValue), fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
                left: BorderSide(
                    width: 1,
                    color: index == count - 1
                        ? Colors.transparent
                        : Color(ZColors.lineColor))),
          ),
          margin: EdgeInsets.only(left: 23),
          padding: EdgeInsets.fromLTRB(22, 6, 16, 30),
          child: Text(
            eventViewModel.actionTarget,
            style: TextStyle(
              color: Color(ZColors.textSecondaryValue),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class EventViewModel {
  String actionUser;
  String actionUserPic;
  String actionDes;
  String actionTime;
  String actionTarget;

  EventViewModel(this.actionUser, this.actionUserPic, this.actionDes,
      this.actionTime, this.actionTarget);

  EventViewModel.fromEventMap(Event event) {
    var date = event.createdAt;
    actionTime = "${date.year.toString()}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
    actionUser = event.actor.login;
    actionUserPic = event.actor.avatar_url;
    var other = EventUtils.getActionAndDes(event);
    actionDes = other["des"];
    actionTarget = other["actionStr"];
  }
}
