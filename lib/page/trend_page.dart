import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/model/TrendingRepoModel.dart';
import 'package:github_app_flutter/widget/drop_down_filter.dart';
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

  TrendTypeModel selectTime = TrendTypeModel("今日", "daily");
  TrendTypeModel selectType = TrendTypeModel("全部", null);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Container(
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 44),
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

  ///头部筛选Items
  Widget _renderHeadItems() =>
      Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        DropDownFilter(
          buttons: [
            FilterButtonModel(
                selectedModel: selectTime,
                contents: trendTime(),
                onSelect: (TrendTypeModel trendModel) {
                  selectTime = trendModel;
                  CommonUtils.showToast('筛选时间： ${trendModel.name}');
                }),
            FilterButtonModel(
                selectedModel: selectType,
                contents: trendType(),
                onSelect: (TrendTypeModel trendModel) {
                  selectType = trendModel;
                  CommonUtils.showToast('筛选语言： ${trendModel.name}');
                }),
          ],
        ),
      ]);

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

  ///趋势数据时间过滤
  List<TrendTypeModel> trendTime() {
    return [
      TrendTypeModel("今日", "daily"),
      TrendTypeModel("本周", "weekly"),
      TrendTypeModel("本月", "monthly"),
    ];
  }

  ///趋势数据语言过滤
  List<TrendTypeModel> trendType() {
    return [
      TrendTypeModel("全部", null),
      TrendTypeModel("Assembly", "Assembly"),
      TrendTypeModel("C", "C"),
      TrendTypeModel("C#", "c%23"),
      TrendTypeModel("C++", "C++"),
      TrendTypeModel("Clojure", "Clojure"),
      TrendTypeModel("CSS", "CSS"),
      TrendTypeModel("CoffeeScript", "CoffeeScript"),
      TrendTypeModel("Dart", "Dart"),
      TrendTypeModel("Go", "Go"),
      TrendTypeModel("Haskell", "Haskell"),
      TrendTypeModel("HTML", "HTML"),
      TrendTypeModel("Java", "Java"),
      TrendTypeModel("JavaScript", "JavaScript"),
      TrendTypeModel("Jupyter Notebook", "Jupyter%20Notebook"),
      TrendTypeModel("Kotlin", "Kotlin"),
      TrendTypeModel("Lua", "Lua"),
      TrendTypeModel("Makefile", "Makefile"),
      TrendTypeModel("Objective-C", "Objective-C"),
      TrendTypeModel("Perl", "Perl"),
      TrendTypeModel("PHP", "PHP"),
      TrendTypeModel("Python", "Python"),
      TrendTypeModel("Ruby", "Ruby"),
      TrendTypeModel("Rust", "Rust"),
      TrendTypeModel("Scala", "Scala"),
      TrendTypeModel("Shell", "Shell"),
      TrendTypeModel("Swift", "Swift"),
      TrendTypeModel("TypeScript", "TypeScript"),
      TrendTypeModel("Vim script", "Vim%20script"),
      TrendTypeModel("Vue", "Vue"),
    ];
  }
}
