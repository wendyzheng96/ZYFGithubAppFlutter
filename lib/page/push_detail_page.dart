import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/dao/repos_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/html_utils.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/model/CommitFile.dart';
import 'package:github_app_flutter/model/PushCommit.dart';
import 'package:github_app_flutter/widget/common_option_widget.dart';
import 'package:github_app_flutter/widget/push_header.dart';

/// 仓库提交详情
/// Create by zyf
/// Date: 2019/8/5
class PushDetailPage extends StatefulWidget {
  final String username;

  final String reposName;

  final String sha;

  final bool needHomeIcon;

  PushDetailPage(this.username, this.reposName, this.sha,
      {this.needHomeIcon = false});

  @override
  _PushDetailPageState createState() => _PushDetailPageState();
}

class _PushDetailPageState extends State<PushDetailPage>
    with AutomaticKeepAliveClientMixin {
  ///标题栏右侧显示控制
  final OptionControl titleOptionControl = OptionControl();

  ///控制刷新状态
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  ///提交信息页面的头部数据实体
  PushHeaderModel headerModel = PushHeaderModel();

  ///提交文件列表
  List<CommitFile> fileList = List();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    showRefreshLoading();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget rightContent = (widget.needHomeIcon)
        ? IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              NavigatorUtils.goReposDetail(
                  context, widget.username, widget.reposName);
            })
        : CommonOptionWidget(titleOptionControl);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reposName),
        actions: <Widget>[rightContent],
      ),
      body: RefreshIndicator(
        key: refreshKey,
        child: ListView.builder(
          itemBuilder: _itemBuilder(),
          itemCount: fileList.length + 1,
        ),
        onRefresh: _getPushInfo,
      ),
    );
  }

  _itemBuilder() => (BuildContext context, int index) {
        if (index == 0) {
          return PushHeader(headerModel);
        }
        PushCodeModel codeModel = PushCodeModel.fromMap(fileList[index - 1]);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.insert_drive_file,
                size: 24.0,
                color: Colors.grey,
              ),
              title: Text(
                codeModel.path,
                style: ZStyles.smallTextSecondary,
              ),
              onTap: () {
                String html = HtmlUtils.generateCode2HTml(
                  HtmlUtils.parseDiffSource(codeModel.patch, false),
                  lang: '',
                  userBR: false,
                );
                NavigatorUtils.gotoCodeDetailPageWeb(
                  context,
                  title: codeModel.name,
                  username: widget.username,
                  reposName: widget.reposName,
                  path: codeModel.patch,
                  data: Uri.dataFromString(
                    html,
                    mimeType: 'text/html',
                    encoding: Encoding.getByName("utf-8"),
                  ).toString(),
                  branch: "",
                );
              },
            ),
            Divider(
              height: 1,
            ),
          ],
        );
      };

  Future<void> _getPushInfo() async {
    var res = await ReposDao.getReposCommitsInfo(
        widget.username, widget.reposName, widget.sha);
    if (res != null && res.result) {
      PushCommit pushCommit = res.data;
      setState(() {
        headerModel = PushHeaderModel.forMap(pushCommit);
        fileList.clear();
        fileList.addAll(pushCommit.files);
        titleOptionControl.url = pushCommit.htmlUrl;
      });
    }
  }

  ///显示刷新
  showRefreshLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      refreshKey.currentState.show().then((e) {});
      return true;
    });
  }
}

class PushCodeModel {
  String path;
  String name;
  String patch;

  String blobUrl;

  PushCodeModel();

  PushCodeModel.fromMap(CommitFile map) {
    String filename = map.fileName;
    List<String> nameSplit = filename.split("/");
    name = nameSplit[nameSplit.length - 1];
    path = filename;
    patch = map.patch;
    blobUrl = map.blobUrl;
  }
}
