import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/model/EventViewModel.dart';

/// 仓库提交item
/// Create by zyf
/// Date: 2019/7/31
class CommitItem extends StatelessWidget {
  final EventViewModel eventViewModel;

  final VoidCallback onPressed;

  final bool needImage;

  CommitItem(this.eventViewModel, {this.onPressed, this.needImage = true});

  @override
  Widget build(BuildContext context) {
    Widget userImage = (needImage)
        ? RawMaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.only(right: 5),
            constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            child: ClipOval(
              child: FadeInImage(
                placeholder: AssetImage(ZIcons.DEFAULT_USER_ICON),
                image: NetworkImage(eventViewModel.actionUserPic),
                fit: BoxFit.fitWidth,
                width: 36,
                height: 36,
              ),
            ),
            onPressed: onPressed,
          )
        : Container();

    Widget des =
        (eventViewModel.actionDes == null || eventViewModel.actionDes.isEmpty)
            ? Container()
            : Container(
                padding: EdgeInsets.only(top: 10),
                alignment: Alignment.topLeft,
                child: Text(
                  eventViewModel.actionDes,
                  style: ZStyles.minTextHint,
                  maxLines: 3,
                ),
              );

    return Card(
      elevation: 3,
      margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: FlatButton(
        padding: EdgeInsets.all(10),
        onPressed: onPressed,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                userImage,
                Expanded(
                    child: Text(
                  eventViewModel.actionUser,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZStyles.normalTextPrimary,
                )),
                Text(
                  eventViewModel.actionTime,
                  style: ZStyles.minTextSecondary,
                )
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(top: 10),
              child: Text(
                eventViewModel.actionTarget,
                style: ZStyles.smallTextPrimary,
              ),
            ),
            des
          ],
        ),
      ),
    );
  }
}
