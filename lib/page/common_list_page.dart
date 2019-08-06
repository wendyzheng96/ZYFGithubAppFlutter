import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/dao/repos_dao.dart';
import 'package:github_app_flutter/common/dao/user_dao.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/widget/dynamic_list_view.dart';
import 'package:github_app_flutter/widget/repos_item.dart';
import 'package:github_app_flutter/widget/user_item.dart';

/// 通用list页
/// Create by zyf
/// Date: 2019/7/29
class CommonListPage extends StatefulWidget {
  final String username;

  final String reposName;

  final String showType;

  final String dataType;

  final String title;

  CommonListPage(this.title, this.showType, this.dataType,
      {this.username, this.reposName});

  @override
  _CommonListPageState createState() => _CommonListPageState();
}

class _CommonListPageState extends State<CommonListPage>
    with AutomaticKeepAliveClientMixin {
  int _page = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: DynamicListView.build(
          itemBuilder: _itemBuilder(),
          dataRequester: _dataRequester,
          initRequester: _initRequester,
        ),
      ),
    );
  }

  Function _itemBuilder() => (List dataList, BuildContext context, int index) {
        var data = dataList[index];
        switch (widget.showType) {
          case 'repository':
            ReposViewModel reposModel = ReposViewModel.fromMap(data);
            return ReposItem(
              reposModel,
              onPressed: () {
                NavigatorUtils.goReposDetail(
                    context, reposModel.ownerName, reposModel.repositoryName);
              },
            );
          case 'user':
            return UserItem(
              UserItemModel.fromMap(data),
              onPressed: () {
                NavigatorUtils.goPersonPage(context, data.login);
              },
            );
          case 'org':
            return UserItem(
              UserItemModel.fromOrgMap(data),
              onPressed: () {
                NavigatorUtils.goPersonPage(context, data.login);
              },
            );
          default:
            return null;
        }
      };

  _initRequester() async {
    _page = 1;
    return await _getData();
  }

  _dataRequester() async {
    _page++;
    return await _getData();
  }

  _getData() async {
    switch (widget.dataType) {
      case 'user_repos':///用户仓库
        return await ReposDao.getUserRepos(widget.username, _page, null,
                needDb: _page <= 1)
            .then((res) {
          return res.data;
        });
      case 'user_star':///用户star
        return await ReposDao.getStarRepos(widget.username, _page, null,
                needDb: _page <= 1)
            .then((res) {
          return res.data;
        });
      case 'followed':///用户关注人列表
        return await UserDao.getFollowedList(widget.username, _page,
                needDb: _page <= 1)
            .then((res) {
          return res.data;
        });
      case 'follower':///用户粉丝列表
        return await UserDao.getFollowerList(widget.username, _page,
                needDb: _page <= 1)
            .then((res) {
          return res.data;
        });
      case 'repo_star':///仓库收藏人列表
        return await ReposDao.getReposStar(
                widget.username, widget.reposName, _page,
                needDb: _page <= 1)
            .then((res) {
          return res.data;
        });
      case 'repo_watcher':///仓库订阅人列表
        return await ReposDao.getReposWatcher(
                widget.username, widget.reposName, _page,
                needDb: _page <= 1)
            .then((res) {
          return res.data;
        });
      case 'repo_fork':///仓库分支表
        return await ReposDao.getReposForks(
                widget.username, widget.reposName, _page,
                needDb: _page <= 1)
            .then((res) {
          return res.data;
        });
      case 'history':///用户阅读历史表
        return await ReposDao.getHistoryDao(_page).then((res) {
          return res.data;
        });
      case 'topics':///标签相关仓库表
        return await ReposDao.searchTopicRepos(widget.username, page: _page)
            .then((res) {
          return res.data;
        });
    }
  }
}
