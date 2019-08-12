import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/dao/repos_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/model/FileModel.dart';
import 'package:github_app_flutter/page/repository_detail_page.dart';

/// 仓库文件列表页
/// Create by zyf
/// Date: 2019/7/31
class ReposFilePage extends StatefulWidget {
  ///用户名
  final String username;

  ///仓库名
  final String reposName;

  ReposFilePage(this.username, this.reposName);

  @override
  _ReposFilePagePage createState() => _ReposFilePagePage();
}

class _ReposFilePagePage extends State<ReposFilePage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  List<String> headerList = ["."];

  List<FileModel> fileList = List();

  String path = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    showRefreshLoading();
    _getFileList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: _renderHeader(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: Container(),
        elevation: 0.0,
      ),
      body: WillPopScope(
        child: RefreshIndicator(
            key: refreshKey,
            child: ListView.builder(
                itemBuilder: (context, index) => _renderItem(index),
                itemCount: fileList.length),
            onRefresh: _getFileList),
        onWillPop: () {
          return _dialogExitApp(context);
        },
      ),
    );
  }

  ///渲染文件列表
  _renderItem(int index) {
    FileItemViewModel model = FileItemViewModel.fromMap(fileList[index]);
    IconData iconData;
    Widget trailing;

    Color color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Color(ZColors.textSecondaryValue);

    if (model.type == 'file') {
      iconData = Icons.insert_drive_file;
      trailing = null;
    } else {
      iconData = Icons.folder;
      trailing = Icon(ZIcons.REPOS_ITEM_NEXT, size: 12.0);
    }
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(model.name, style: TextStyle(color: color, fontSize: 14)),
          leading: Icon(
            iconData,
            size: 24.0,
            color: (model.type == "file") ? Colors.grey : Colors.orangeAccent,
          ),
          onTap: () {
            _resolveItemClick(model);
          },
          trailing: trailing,
        ),
        Container(
          padding: EdgeInsets.only(left: 70),
          child: Divider(
            height: 1.0,
            color: Theme.of(context).dividerColor,
          ),
        )
      ],
    );
  }

  ///item文件列表点击
  _resolveItemClick(FileItemViewModel model) {
    if (model.type == "dir") {
      this.setState(() {
        headerList.add(model.name);
      });
      String path = headerList.sublist(1, headerList.length).join("/");
      this.setState(() {
        this.path = path;
      });
      this.showRefreshLoading();
    } else {
      String filePath =
          headerList.sublist(1, headerList.length).join("/") + "/" + model.name;
      if (CommonUtils.isImageEnd(model.name)) {
        NavigatorUtils.gotoPhotoPage(context, model.htmlUrl + "?raw=true");
      } else {
        NavigatorUtils.gotoCodeDetailPageWeb(
          context,
          title: model.name,
          username: widget.username,
          reposName: widget.reposName,
          path: filePath,
          branch: ReposDetailModel.of(context).currentBranch,
        );
      }
    }
  }

  ///渲染头部列表
  _renderHeader() {
    return Container(
      margin: EdgeInsets.only(left: 3.0, right: 3.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return RawMaterialButton(
            constraints: BoxConstraints(minWidth: 0.0, minHeight: 0.0),
            padding: EdgeInsets.all(4.0),
            onPressed: () {
              _resolveHeaderClick(index);
            },
            child: Row(
              children: <Widget>[
                Text(headerList[index] + " "),
                Icon(
                  ZIcons.REPOS_ITEM_NEXT,
                  size: 12.0,
                  color: Color(ZColors.textHintValue),
                ),
              ],
            ),
          );
        },
        itemCount: headerList.length,
      ),
    );
  }

  ///头部列表点击
  _resolveHeaderClick(index) {
    if (headerList[index] != ".") {
      List<String> newHeaderList = headerList.sublist(0, index + 1);
      String path = newHeaderList.sublist(1, newHeaderList.length).join("/");
      this.setState(() {
        this.path = path;
        headerList = newHeaderList;
      });
      this.showRefreshLoading();
    } else {
      setState(() {
        path = "";
        headerList = ["."];
      });
      this.showRefreshLoading();
    }
  }

  /// 返回按键逻辑
  Future<bool> _dialogExitApp(BuildContext context) {
    if (ReposDetailModel.of(context).currentIndex != 3) {
      return Future.value(true);
    }
    if (headerList.length == 1) {
      return Future.value(true);
    } else {
      _resolveHeaderClick(headerList.length - 2);
      return Future.value(false);
    }
  }

  showRefreshLoading() {
    new Future.delayed(const Duration(seconds: 0), () {
      refreshKey.currentState.show().then((e) {});
      return true;
    });
  }

  Future<void> _getFileList() async {
    await ReposDao.getReposFileDir(widget.username, widget.reposName,
            path: path, branch: ReposDetailModel.of(context).currentBranch)
        .then((res) {
      setState(() {
        fileList = res.data ?? List();
      });
    });
  }
}

class FileItemViewModel {
  String type;
  String name;
  String htmlUrl;

  FileItemViewModel();

  FileItemViewModel.fromMap(FileModel map) {
    name = map.name;
    type = map.type;
    htmlUrl = map.htmlUrl;
  }
}
