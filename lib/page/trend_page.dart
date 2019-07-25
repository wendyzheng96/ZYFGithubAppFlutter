import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/dao/repos_dao.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
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
  bool isSelectTime = false;
  bool isSelectLanguage = false;

  TrendTypeModel selectTime = TrendTypeModel("今日", "daily");
  TrendTypeModel selectLanguage = TrendTypeModel("全部", null);

  List<TrendingRepoModel> trendList;

  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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
            child: trendList == null
                ? _loadingProgress(Theme.of(context).primaryColor)
                : RefreshIndicator(
                    child: ListView.builder(
                        itemCount: trendList.length,
                        itemBuilder: (context, index) {
                          ReposViewModel repoModel =
                              ReposViewModel.fromTrendMap(trendList[index]);
                          return ReposItem(
                            repoModel,
                            onPressed: () {
                              CommonUtils.showToast('趋势 $index');
                            },
                          );
                        }),
                    onRefresh: _getTrendRepos),
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
                selectedModel: selectLanguage,
                contents: trendType(),
                onSelect: (TrendTypeModel trendModel) {
                  selectLanguage = trendModel;
                  CommonUtils.showToast('筛选语言： ${trendModel.name}');
                }),
          ],
        ),
      ]);

  Widget _loadingProgress(loadingColor) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
      ),
    );
  }

  ///获取趋势数据
  Future<void> _getTrendRepos() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    return await ReposDao.getTrendRepos(
            since: selectTime.value, languageType: selectLanguage.value)
        .then((res) {
      setState(() {
        _isLoading = false;
        if (res.data != null) {
          trendList = res.data;
        } else {
          trendList = List();
        }
      });
    });
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
