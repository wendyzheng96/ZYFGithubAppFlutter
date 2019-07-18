import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/model/TrendingRepoModel.dart';
import 'package:github_app_flutter/widget/dynamic_list_view.dart';
import 'package:github_app_flutter/widget/repos_item.dart';

/// 趋势页面
/// Create by zyf
/// Date: 2019/7/15
class TrendPage extends StatefulWidget {
  @override
  _TrendPageState createState() => _TrendPageState();
}

class _TrendPageState extends State<TrendPage>
    with AutomaticKeepAliveClientMixin {
  bool isSelectTime = false;
  bool isSelectType = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
//        color: Color(ZColors.mainBackgroundColor),
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 48),
            child: DynamicListView.build(
              itemBuilder: _itemBuilder(),
              dataRequester: _dataRequester,
              initRequester: _initRequester,
              dividerColor: Colors.transparent,
            ),
          ),
          _renderHeadItems(),
        ],
      ),
    ));
  }

  ///头部Items
  Widget _renderHeadItems() => Container(
        decoration:
            BoxDecoration(color: Theme.of(context).primaryColor, boxShadow: [
          BoxShadow(
            blurRadius: 6,
            spreadRadius: 4,
            color: Color.fromARGB(50, 0, 0, 0),
          )
        ]),
        child: Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton.icon(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                elevation: 0,
                highlightElevation: 0,
                disabledElevation: 0,
                icon: Icon(
                  isSelectTime ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  '今日',
                  style: ZStyles.middleTextWhite,
                ),
                onPressed: () {///选择时间
                  setState(() {
                    isSelectTime = !isSelectTime;
                    isSelectType = false;
                  });
                  CommonUtils.showToast("今日");

                },
              ),
              flex: 1,
            ),
            Container(
              width: 1.0,
              height: 16,
              color: Colors.white,
            ),
            Expanded(
              child: RaisedButton.icon(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                elevation: 0,
                highlightElevation: 0,
                disabledElevation: 0,
                icon: Icon(
                  isSelectType ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  '全部',
                  style: ZStyles.middleTextWhite,
                ),
                onPressed: () {///选择语言
                  setState(() {
                    isSelectType = !isSelectType;
                    isSelectTime = false;
                  });
                  CommonUtils.showToast("全部");
                },
              ),
              flex: 1,
            ),
          ],
        ),
      );

  ///刷新数据
  Future<List<ReposViewModel>> _initRequester() async {
    TrendingRepoModel trendModel = TrendingRepoModel(
        '',
        "Nike",
        <String>[
          'https://hbimg.huabanimg.com/10af2edaadbdebac80dde620a643fb9132167d7b4c1ec-WRzj8W_fw658'
        ],
        '',
        'PHPMailer/PHPMailer',
        "仓库描述是但还是觉得还是说的话creat comment on issue 15580 in 996icu/996ICU",
        "Java",
        "121",
        "105",
        "80",
        "DHUDD");
    return Future.value(
        List.generate(10, (i) => ReposViewModel.fromTrendMap(trendModel)));
  }

  ///加载更多数据
  Future<List<ReposViewModel>> _dataRequester() async {
    TrendingRepoModel trendModel = TrendingRepoModel(
        '',
        "Nike",
        <String>[
          'https://hbimg.huabanimg.com/0d2a3fca3b1829736261fdf7db36d8001ecb0ea715f10c-3Dv8Bn_fw658'
        ],
        '',
        '仓库名称',
        "仓库描述creat comment on issue 15580 in 996icu/996ICU",
        "Dart",
        "121",
        "105",
        "93",
        "DHUDD");
    return Future.value(
        List.generate(10, (i) => ReposViewModel.fromTrendMap(trendModel)));
  }

  //仓库Item布局加载
  Function _itemBuilder() => (List dataList, BuildContext context, int index) {
        ReposViewModel repoModel = dataList[index];
        return ReposItem(
          repoModel,
          onPressed: () {
            CommonUtils.showToast('趋势 $index');
          },
        );
      };

  ///或者头部可选弹出item容器
  _renderHeaderPopItem(String data, List<TrendTypeModel> list,
      PopupMenuItemSelected<TrendTypeModel> onSelected) {
    return new Expanded(
      child: new PopupMenuButton<TrendTypeModel>(
        child: new Center(
            child: new Text(data, style: ZStyles.middleTextWhite)),
        onSelected: onSelected,
        itemBuilder: (BuildContext context) {
          return _renderHeaderPopItemChild(list);
        },
      ),
    );
  }

  ///或者头部可选弹出item
  _renderHeaderPopItemChild(List<TrendTypeModel> data) {
    List<PopupMenuEntry<TrendTypeModel>> list = new List();
    for (TrendTypeModel item in data) {
      list.add(PopupMenuItem<TrendTypeModel>(
        value: item,
        child: new Text(item.name),
      ));
    }
    return list;
  }
}

///趋势数据过滤显示item
class TrendTypeModel {
  final String name;
  final String value;

  TrendTypeModel(this.name, this.value);
}

///趋势数据时间过滤
trendTime(BuildContext context) {
  return [
    new TrendTypeModel("今日", "daily"),
    new TrendTypeModel("本周", "weekly"),
    new TrendTypeModel("本月", "monthly"),
  ];
}

///趋势数据语言过滤
trendType(BuildContext context) {
  return [
    TrendTypeModel("全部", null),
    TrendTypeModel("Java", "Java"),
    TrendTypeModel("Kotlin", "Kotlin"),
    TrendTypeModel("Dart", "Dart"),
    TrendTypeModel("Objective-C", "Objective-C"),
    TrendTypeModel("Swift", "Swift"),
    TrendTypeModel("JavaScript", "JavaScript"),
    TrendTypeModel("PHP", "PHP"),
    TrendTypeModel("Go", "Go"),
    TrendTypeModel("C++", "C++"),
    TrendTypeModel("C", "C"),
    TrendTypeModel("HTML", "HTML"),
    TrendTypeModel("CSS", "CSS"),
    TrendTypeModel("Python", "Python"),
    TrendTypeModel("C#", "c%23"),
  ];
}

