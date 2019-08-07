import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/dao/repos_dao.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/model/TrendingRepoModel.dart';
import 'package:github_app_flutter/widget/drop_down_filter.dart';
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
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool isSelectTime = false;
  bool isSelectLanguage = false;

  TrendTypeModel selectTime;
  TrendTypeModel selectLanguage;

  List<TrendingRepoModel> trendList = List();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    setState(() {
      selectTime = trendTime()[0];
      selectLanguage = languageType()[0];
    });
    showRefreshLoading();
    _getTrendRepos();
  }

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
              child: RefreshIndicator(
                key: refreshIndicatorKey,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: trendList.length,
                  itemBuilder: (context, index) {
                    ReposViewModel repoModel =
                        ReposViewModel.fromTrendMap(trendList[index]);
                    return ReposItem(
                      repoModel,
                      onPressed: () {
                        NavigatorUtils.goReposDetail(context,
                            repoModel.ownerName, repoModel.repositoryName);
                      },
                    );
                  },
                ),
                onRefresh: _getTrendRepos,
              ),
            ),
            _renderHeadItems(),
          ],
        ),
      ),
    );
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
                  showRefreshLoading();
                  _getTrendRepos();
                }),
            FilterButtonModel(
                selectedModel: selectLanguage,
                contents: languageType(),
                onSelect: (TrendTypeModel trendModel) {
                  selectLanguage = trendModel;
                  showRefreshLoading();
                  _getTrendRepos();
                }),
          ],
        ),
      ]);

  ///显示刷新
  showRefreshLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      refreshIndicatorKey.currentState.show().then((e) {});
      return true;
    });
  }

  ///获取趋势数据
  Future<void> _getTrendRepos() async {
    return await ReposDao.getTrendRepos(
            since: selectTime.value, languageType: selectLanguage.value)
        .then((res) {
      setState(() {
        trendList = res.data ?? List();
      });
    });
  }
}

///趋势数据时间过滤
List<TrendTypeModel> trendTime() {
  return [
    TrendTypeModel("今日", "daily"),
    TrendTypeModel("本周", "weekly"),
    TrendTypeModel("本月", "monthly"),
  ];
}

///趋势数据语言过滤
List<TrendTypeModel> languageType() {
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
