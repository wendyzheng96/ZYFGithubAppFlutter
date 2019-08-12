import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/dao/repos_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/model/Repository.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/page/trend_page.dart';
import 'package:github_app_flutter/widget/drop_down_filter.dart';
import 'package:github_app_flutter/widget/dynamic_list_view.dart';
import 'package:github_app_flutter/widget/repos_item.dart';
import 'package:github_app_flutter/widget/user_item.dart';

/// 搜索页面
/// Create by zyf
/// Date: 2019/7/23
class SearchPage extends StatefulWidget {
  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  final TextEditingController inputController = TextEditingController();

  final List<TrendTypeModel> types = [
    TrendTypeModel("仓库", null),
    TrendTypeModel("用户", "user"),
  ];

  TabController _tabController;

  String _searchContent = '';

  int _page = 1;

  String searchType;

  ///排序类型
  TrendTypeModel orderBy = orderType[0];

  ///排序
  TrendTypeModel sort = sortType[0];

  ///过滤语言
  TrendTypeModel language = languageType()[0];

  List<String> searchKeyList = List();

  ///是否显示搜索结果
  bool isShowResult = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: types.length,
      vsync: ScaffoldState(),
    );
    _getSearchKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          flexibleSpace: _searchWidget(),
        ),
        body: Stack(
          children: <Widget>[
            Offstage(
              offstage: isShowResult,
              child: _searchHistoryWidget(),
            ),
            Offstage(
              offstage: !isShowResult,
              child: Column(
                children: <Widget>[
                  Container(
                    color: Theme.of(context).primaryColor,
                    child: TabBar(
                      tabs: types.map((TrendTypeModel f) {
                        return Text(f.name);
                      }).toList(),
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Colors.white,
                      labelPadding: EdgeInsets.only(bottom: 10),
                      labelStyle:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      onTap: (index) {
                        searchType = types[index].value;
                        showRefreshLoading();
                      },
                    ),
                  ),
                  Expanded(
                    child: DynamicListView.build(
                      itemBuilder: _renderItem(),
                      dataRequester: _dataRequester,
                      initRequester: _initRequester,
                      isLoadDataFirst: false,
                      refreshKey: refreshKey,
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  _searchWidget() => Container(
        padding: EdgeInsets.fromLTRB(16, 28, 0, 0),
        color: Theme.of(context).primaryColor,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Icon(
                        ZIcons.SEARCH,
                        size: 14,
                        color: Color(ZColors.textHintValue),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        autofocus: false,
                        controller: inputController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(8),
                          hintText: '请输入搜索内容',
                          hintStyle: TextStyle(
                            color: Color(ZColors.textHintValue),
                            fontSize: 14,
                          ),
                        ),
                        maxLines: 1,
                        onChanged: (String value) {
                          setState(() {
                            _searchContent = value;
                            if (_searchContent.isEmpty) {
                              ///清空搜索框
                              isShowResult = false;
                              showRefreshLoading();
                            }
                          });
                        },
                        style: TextStyle(
                          color: Color(ZColors.textPrimaryValue),
                          fontSize: 14,
                        ),
                        textInputAction: TextInputAction.search,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          showRefreshLoading();
                        },
                      ),
                    ),
                    RawMaterialButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      constraints: BoxConstraints(minWidth: 10, minHeight: 10),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      onPressed: () {
                        ///清空搜索框
                        inputController.clear();
                        setState(() {
                          _searchContent = "";
                          isShowResult = false;
                        });
                        showRefreshLoading();
                      },
                      child: _searchContent.isEmpty
                          ? Container()
                          : Icon(
                              Icons.cancel,
                              size: 15,
                              color: Colors.grey,
                            ),
                    ),
                  ],
                ),
              ),
            ),
            RawMaterialButton(
              constraints: BoxConstraints(minHeight: 0, minWidth: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Text(
                '取消',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );

  ///搜索历史
  _searchHistoryWidget(){
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 10, 10, 6),
                    child: Text(
                      '搜索历史',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  )),
              RawMaterialButton(
                child: Text(
                  '清空',
                  style: ZStyles.smallerTextSecondary,
                ),
                constraints: BoxConstraints(minWidth: 0, minHeight: 0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                onPressed: () {
                  _clearHistory();
                },
              )
            ],
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return RawMaterialButton(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        color: Color(ZColors.textHintValue),
                        size: 16,
                      ),
                      Container(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          searchKeyList[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(ZColors.textPrimaryValue),
                          ),
                        ),
                      ),
                      RawMaterialButton(
                        onPressed: () {
                          _deleteSearchKey(index);
                        },
                        child: Icon(
                          Icons.close,
                          color: Color(ZColors.textHintValue),
                          size: 16,
                        ),
                        constraints:
                        BoxConstraints(minHeight: 0, minWidth: 0),
                        materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                        padding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                  onPressed: () {
                    inputController.value =
                        TextEditingValue(text: searchKeyList[index]);
                    setState(() {
                      _searchContent = searchKeyList[index];
                    });
                    showRefreshLoading();
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Container(
                  child: Divider(height: 1),
                  padding: EdgeInsets.symmetric(horizontal: 14),
                );
              },
              itemCount: searchKeyList.length,
            ),
          )
        ],
      ),
    );
  }

  _renderItem() => (List dataList, BuildContext context, int index) {
        var data = dataList[index];
        if (data is User) {
          return UserItem(
            UserItemModel.fromMap(data),
            onPressed: () {
              NavigatorUtils.goPersonPage(context, data.login);
            },
          );
        }
        if(data is Repository) {
          ReposViewModel reposModel = ReposViewModel.fromMap(data);
          return ReposItem(
            reposModel,
            onPressed: () {
              NavigatorUtils.goReposDetail(
                  context, reposModel.ownerName, reposModel.repositoryName);
            },
          );
        }
        return null;
      };

  ///刷新数据
  showRefreshLoading() {
    setState(() {
      isShowResult = _searchContent.isNotEmpty;
    });
    Future.delayed(const Duration(seconds: 0), () {
      refreshKey.currentState.show().then((e) {});
      return true;
    });
  }

  _initRequester() async {
    _saveSearchKey(_searchContent);
    _getSearchKeys();
    _page = 1;
    return await _getSearchResult();
  }

  _dataRequester() async {
    _page++;
    return await _getSearchResult();
  }

  ///获取搜索结果
  _getSearchResult() async {
    if (_searchContent == null || _searchContent.isEmpty) {
      return List();
    }
    return await ReposDao.searchRepositoryDao(_searchContent, null,
            'best%20match', 'desc', searchType, _page, Config.PAGE_SIZE)
        .then((res) {
      return res.data ?? List();
    });
  }

  ///获取搜索历史
  _getSearchKeys() async {
    await ReposDao.getSearchHistory().then((res) {
      if (res != null && res.result) {
        setState(() {
          searchKeyList = res.data;
        });
      }
    });
  }

  ///保存搜索历史
  _saveSearchKey(String keyword) async {
    if (keyword == null || keyword.isEmpty) {
      return;
    }
    await ReposDao.saveSearchKey(keyword);
  }

  ///删除关键词
  _deleteSearchKey(int index) async {
    await ReposDao.deleteSearchKey(searchKeyList[index]).then(
        setState(() {
          searchKeyList.removeAt(index);
        })
    );
  }

  ///清空搜索历史
  _clearHistory() async {
    await ReposDao.clearSearchHistory().then(
        setState(() {
          searchKeyList.clear();
        })
    );
  }
}

///排序类型
List<TrendTypeModel> orderType = [
  TrendTypeModel("best", "best%20match"),
  TrendTypeModel("stars", "stars"),
  TrendTypeModel("forks", "forks"),
  TrendTypeModel("updated", "updated"),
];

///排序
List<TrendTypeModel> sortType = [
  TrendTypeModel("desc", "desc"),
  TrendTypeModel("asc", "asc"),
];
