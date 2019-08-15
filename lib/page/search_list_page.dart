import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/dao/repos_dao.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/model/Repository.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/widget/dynamic_list_view.dart';
import 'package:github_app_flutter/widget/repos_item.dart';
import 'package:github_app_flutter/widget/user_item.dart';

/// 搜索结果页
/// Create by zyf
/// Date: 2019/8/15
class SearchListPage extends StatefulWidget {
  final String searchContent;

  final String searchType;

  SearchListPage(this.searchContent, this.searchType, {Key key})
      : super(key: key);

  @override
  SearchListPageState createState() => SearchListPageState();
}

class SearchListPageState extends State<SearchListPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey();

  int _page = 1;

  bool _isComplete = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: DynamicListView.build(
        itemBuilder: _renderItem(),
        dataRequester: _dataRequester,
        initRequester: _initRequester,
        isLoadComplete: _isComplete,
        refreshKey: refreshKey,
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
        if (data is Repository) {
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
    Future.delayed(const Duration(seconds: 0), () {
      refreshKey.currentState.show().then((e) {});
      return true;
    });
  }

  _initRequester() async {
    _page = 1;
    return await _getSearchResult();
  }

  _dataRequester() async {
    _page++;
    return await _getSearchResult();
  }

  ///获取搜索结果
  _getSearchResult() async {
    if (widget.searchContent == null || widget.searchContent.isEmpty) {
      return List();
    }
    return await ReposDao.searchRepositoryDao(widget.searchContent, null,
            'best%20match', 'desc', widget.searchType, _page, Config.PAGE_SIZE)
        .then((res) {
      if (!res.result) {
        _page--;
      }
      setState(() {
        _isComplete = (res.result && res.data.length < Config.PAGE_SIZE);
      });
      return res.data ?? List();
    });
  }
}
