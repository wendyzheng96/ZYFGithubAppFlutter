import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/model/event.dart';
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

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
      color: Colors.white,
      child: DynamicListView.build(
        itemBuilder: _itemBuilder(),
        dataRequester: _dataRequester,
        initRequester: _initRequester,
        dividerColor: Colors.transparent,
      ),
    ));
  }

  Future<List<EventViewModel>> _initRequester() async {
    return Future.value(List.generate(
        10,
        (i) => EventViewModel(
              "Nike$i",
              "https://hbimg.huabanimg.com/0d2a3fca3b1829736261fdf7db36d8001ecb0ea715f10c-3Dv8Bn_fw658",
              '苏丹红事件但还是觉得寒暑假回家世界上的四大金刚傻瓜大好时光',
              '2019/07/15 17:09',
              "creat comment on issue 15580 in 996icu/996ICU",
            )));
  }

  Future<List<EventViewModel>> _dataRequester() async {
    return Future.delayed(Duration(seconds: 2), () {
      return List.generate(
          10,
          (i) => EventViewModel(
              "Nike${10 + i}",
              "https://hbimg.huabanimg.com/0d2a3fca3b1829736261fdf7db36d8001ecb0ea715f10c-3Dv8Bn_fw658",
              '苏丹红事件但还是觉得寒暑假回家世界上的四大金刚傻瓜大好时光',
              '2019/07/15 17:09',
              "creat comment on issue 15580 in 996icu/996ICU"));
    });
  }

  Function _itemBuilder() => (List dataList, BuildContext context, int index) {
        EventViewModel model = dataList[index];
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
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    model.actionTarget,
                    style: TextStyle(
                        color: Color(ZColors.textPrimaryValue),
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  model.actionDes,
                  maxLines: 3,
                  style: TextStyle(
                    color: Color(ZColors.textSecondaryValue),
                    fontSize: 13,
                  ),
                )
              ],
            ),
          ),
          onTap: (){
            //TODO 跳转页面
            CommonUtils.showToast('click $index');
          },
        );
      };
}
