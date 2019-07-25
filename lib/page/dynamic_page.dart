import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:github_app_flutter/common/dao/event_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/common/zyf_state.dart';
import 'package:github_app_flutter/model/Event.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/widget/dynamic_list_view.dart';
import 'package:github_app_flutter/widget/event_item.dart';

/// 动态页
/// Create by zyf
/// Date: 2019/7/15
class DynamicPage extends StatefulWidget {
  @override
  _DynamicPageState createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage>
    with AutomaticKeepAliveClientMixin {
  List<EventViewModel> eventList = [];

  int _page = 1;

  String username = "";

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      child: StoreBuilder<ZYFState>(
        builder: (context, store) {
          User user = store.state.userInfo;
          username = user.login;
          return Scaffold(
              body: Container(
            color: Colors.white,
            child: DynamicListView.build(
              itemBuilder: _itemBuilder(),
              dataRequester: _dataRequester,
              initRequester: _initRequester,
              dividerColor: Colors.transparent,
            ),
          ));
        },
      ),
    );
  }

  Future<List<Event>> _initRequester() async {
    _page = 1;
    return await EventDao.getEventReceived(username, page: _page, needDb: true)
        .then((res) {
      if (res.data != null) {
        return res.data;
      }
      return List<Event>();
    });
  }

  Future<List<Event>> _dataRequester() async {
    _page++;
    return await EventDao.getEventReceived(username, page: _page).then((res) {
      if (res.data != null) {
        return res.data;
      }
      return List<Event>();
    });
  }

  Function _itemBuilder() => (List dataList, BuildContext context, int index) {
        EventViewModel model = EventViewModel.fromEventMap(dataList[index]);
        return GestureDetector(
          child: Container(
            margin: EdgeInsets.fromLTRB(12, 12, 12, 4),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 6,
                      spreadRadius: 4,
                      color: Color.fromARGB(20, 0, 0, 0))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: NetworkImage(model.actionUserPic),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        model.actionUser,
                        style: TextStyle(
                            color: Color(ZColors.textPrimaryValue),
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                        child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        model.actionTime,
                        style: TextStyle(
                            color: Color(ZColors.textHintValue), fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(
                      top: 8, bottom: model.actionDes.isEmpty ? 0 : 8),
                  child: Text(
                    model.actionTarget,
                    style: TextStyle(
                        color: Color(ZColors.textPrimaryValue),
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                model.actionDes.isEmpty
                    ? Container()
                    : Text(
                        model.actionDes,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(ZColors.textSecondaryValue),
                          fontSize: 13,
                        ),
                      )
              ],
            ),
          ),
          onTap: () {
            //TODO 跳转页面
            CommonUtils.showToast('click $index');
          },
        );
      };
}
