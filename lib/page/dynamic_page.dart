import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/dao/event_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/event_utils.dart';
import 'package:github_app_flutter/common/zyf_state.dart';
import 'package:github_app_flutter/model/Event.dart';
import 'package:github_app_flutter/model/EventViewModel.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/widget/dynamic_list_view.dart';

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

  ///是否加载完成
  bool _isComplete = false;

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
              child: DynamicListView.build(
                itemBuilder: _itemBuilder(),
                dataRequester: _dataRequester,
                initRequester: _initRequester,
                isLoadComplete: _isComplete,
              ),
            ),
          );
        },
      ),
    );
  }

  ///刷新数据
  Future<List<Event>> _initRequester() async {
    _page = 1;
    return await _getData();
  }

  ///加载更多
  Future<List<Event>> _dataRequester() async {
    _page++;
    return await _getData();
  }

  ///获取数据
  _getData() async {
    return await EventDao.getEventReceived(username, page: _page).then((res) {
      if (!res.result) {
        _page--;
      }
      setState(() {
        _isComplete = (res.result && res.data.length < Config.PAGE_SIZE);
      });
      return res.data ?? List<Event>();
    });
  }

  Function _itemBuilder() => (List dataList, BuildContext context, int index) {
        EventViewModel model = EventViewModel.fromEventMap(dataList[index]);
        return GestureDetector(
          child: Container(
            margin: EdgeInsets.fromLTRB(12, 12, 12, 4),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
                      backgroundColor: Color(ZColors.imgColor),
                      backgroundImage: NetworkImage(model.actionUserPic),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          model.actionUser,
                          style: Theme.of(context).textTheme.body1.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ),
                    Text(
                      model.actionTime,
                      style: TextStyle(
                        color: Color(ZColors.textHintValue),
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: 8,
                    bottom: model.actionDes.isEmpty ? 0 : 8,
                  ),
                  child: Text(
                    model.actionTarget,
                    style: Theme.of(context).textTheme.body1.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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
            EventUtils.actionUtils(context, dataList[index], "");
          },
        );
      };
}
