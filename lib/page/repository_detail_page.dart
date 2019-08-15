import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/dao/issue_dao.dart';
import 'package:github_app_flutter/common/dao/repos_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/common/utils/dialog_utils.dart';
import 'package:github_app_flutter/model/Repository.dart';
import 'package:github_app_flutter/page/repos_detail_info_page.dart';
import 'package:github_app_flutter/page/repos_file_page.dart';
import 'package:github_app_flutter/page/repos_issue_page.dart';
import 'package:github_app_flutter/page/repos_readme_page.dart';
import 'package:github_app_flutter/widget/common_option_widget.dart';
import 'package:github_app_flutter/widget/icon_text.dart';
import 'package:github_app_flutter/widget/tabbar_widget.dart';
import 'package:scoped_model/scoped_model.dart';

/// 仓库详情
/// Create by zyf
/// Date: 2019/7/26
class RepositoryDetailPage extends StatefulWidget {
  ///用户名
  final String username;

  ///仓库名
  final String reposName;

  RepositoryDetailPage(this.username, this.reposName);

  @override
  _RepositoryDetailPageState createState() => _RepositoryDetailPageState();
}

class _RepositoryDetailPageState extends State<RepositoryDetailPage>
    with SingleTickerProviderStateMixin {
  ///标题栏右侧显示控制
  final OptionControl _optionControl = OptionControl();

  ///仓库的详情数据实体
  final ReposDetailModel reposDetailModel = ReposDetailModel();

  /// 仓库底部状态，如 star、watch 控件的显示
  final TarWidgetControl tarBarControl = TarWidgetControl();

  /// 仓库底部状态，如 star、watch 等等
  BottomStatusModel bottomStatusModel;

  ///分支列表
  List<String> branchList = List();

  GlobalKey<ReposDetailInfoPageState> infoKey = GlobalKey();

  GlobalKey<ReposReadmePageState> readmeKey = GlobalKey();

  GlobalKey<ReposIssuePageState> issueKey = GlobalKey();

  GlobalKey<ReposFilePageState> fileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _getBranchList();
    _getReposStatus();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ReposDetailModel>(
        model: reposDetailModel,
        child: ScopedModelDescendant<ReposDetailModel>(
            builder: (context, child, model) {
          Widget rightContent =
              (model.repository != null && model.repository.htmlUrl != null)
                  ? CommonOptionWidget(
                      _optionControl,
                      otherList: [
                        OptionModel('分支', 'branch', (model) {
                          _showBranchesDialog();
                        })
                      ],
                    )
                  : Container();

          return TabBarWidget(
              indicatorColor: Colors.white,
              resizeToAvoidBottomPadding: false,
              type: TabBarWidget.TOP_TAB,
              tabItems: _renderTabItems(),
              tabViews: <Widget>[
                ReposDetailInfoPage(
                    widget.username, widget.reposName, _optionControl,
                    key: infoKey),
                ReposReadmePage(widget.username, widget.reposName,
                    key: readmeKey),
                ReposIssuePage(widget.username, widget.reposName,
                    key: issueKey),
                ReposFilePage(widget.username, widget.reposName, key: fileKey)
              ],
              title: Text(widget.reposName),
              actions: <Widget>[rightContent],
              onPageChanged: (index) {
                reposDetailModel.setCurrentIndex(index);
              },
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  _createIssue();
                },
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endDocked,
              bottomBar: BottomAppBar(
                shape: CircularNotchedRectangle(),
                child: Row(
                  children: (tarBarControl.footerButton == null)
                      ? [Container()]
                      : tarBarControl.footerButton.length == 0
                          ? [
                              SizedBox.fromSize(
                                size: Size(100, 50),
                              )
                            ]
                          : tarBarControl.footerButton,
                ),
              ));
        }));
  }

  ///渲染 Tab 的 Item
  _renderTabItems() {
    var itemList = [
      '动态',
      '详情',
      'Issue',
      'Code',
    ];
    renderItem(String item, int i) {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            item,
            style: TextStyle(color: Colors.white, fontSize: 15),
            maxLines: 1,
          ));
    }

    List<Widget> list = List();
    for (int i = 0; i < itemList.length; i++) {
      list.add(renderItem(itemList[i], i));
    }
    return list;
  }

  ///绘制底部状态
  List<Widget> _getBottomWidget() {
    List<Widget> bottomWidget = (bottomStatusModel == null)
        ? []
        : <Widget>[
            _renderBottomItem(
                bottomStatusModel.starText, bottomStatusModel.starIcon, () {
              DialogUtils.showLoadingDialog(context);
              ReposDao.doRepositoryStar(
                      widget.username, widget.reposName, bottomStatusModel.star)
                  .then((res) {
                this._getReposStatus();
                Navigator.pop(context);
              });
            }),
            _renderBottomItem(
                bottomStatusModel.watchText, bottomStatusModel.watchIcon, () {
              DialogUtils.showLoadingDialog(context);
              ReposDao.doRepositoryWatcher(widget.username, widget.reposName,
                      bottomStatusModel.watch)
                  .then((res) {
                this._getReposStatus();
                Navigator.pop(context);
              });
            }),
            _renderBottomItem('fork', Icons.share, () {
              DialogUtils.showLoadingDialog(context);
              ReposDao.createForkDao(widget.username, widget.reposName)
                  .then((res) {
                this._getReposStatus();
                Navigator.pop(context);
              });
            }),
          ];
    return bottomWidget;
  }

  ///绘制底部状态item
  _renderBottomItem(String text, IconData icon, VoidCallback onPressed) {
    Color color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Theme.of(context).primaryColorDark;

    return FlatButton(
        onPressed: onPressed,
        child: IconText(
          text,
          icon,
          TextStyle(
            color: color,
            fontSize: 14,
          ),
          iconColor: color,
          iconSize: 16,
          padding: 4,
          mainAxisAlignment: MainAxisAlignment.center,
        ));
  }

  ///获取分支数据
  _getBranchList() async {
    var res = await ReposDao.getBranches(widget.username, widget.reposName);
    if (res != null && res.result) {
      setState(() {
        branchList = res.data;
      });
    }
  }

  ///获取仓库状态，star、watch等
  _getReposStatus() async {
    var res =
        await ReposDao.getRepositoryStatus(widget.username, widget.reposName);
    bool isWatched = res.data["watch"];
    bool isStared = res.data["star"];
    String watchText = isWatched ? 'UnWatch' : 'Watch';
    String starText = isStared ? 'UnStar' : 'Star';
    IconData watchIcon =
        isWatched ? ZIcons.REPOS_ITEM_WATCHED : ZIcons.REPOS_ITEM_WATCH;
    IconData starIcon = isStared ? Icons.star : Icons.star_border;
    BottomStatusModel model = BottomStatusModel(
        watchText, starText, watchIcon, starIcon, isWatched, isStared);
    setState(() {
      bottomStatusModel = model;
      tarBarControl.footerButton = _getBottomWidget();
    });
  }

  ///创建issue
  _createIssue() {
    String title = '';
    String content = '';
    DialogUtils.showEditDialog(
      context,
      'Issue 编译',
      (titleValue) {
        title = titleValue;
      },
      (contentValue) {
        content = contentValue;
      },
      onPressed: () {
        if (title == null || title.isEmpty) {
          CommonUtils.showToast('请输入标题');
          return;
        }
        if (content == null || content.isEmpty) {
          CommonUtils.showToast('请输入内容');
          return;
        }
        DialogUtils.showLoadingDialog(context);
        IssueDao.createIssue(widget.username, widget.reposName,
            {"title": title, "body": content}).then((res) {
          if (issueKey.currentState != null && issueKey.currentState.mounted) {
            issueKey.currentState.showRefreshLoading();
          }
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
      needTitle: true,
      titleController: TextEditingController(),
      contentController: TextEditingController(),
    );
  }

  ///仓库分支信息
  _showBranchesDialog() {
    if (branchList == null || branchList.length == 0) {
      return;
    }
    DialogUtils.showListDialog(context, branchList, onTap: (index) {
      setState(() {
        reposDetailModel.setCurrentBranch(branchList[index]);
      });
      if (infoKey.currentState != null && infoKey.currentState.mounted) {
        infoKey.currentState.showRefreshLoading();
      }
      if (readmeKey.currentState != null && readmeKey.currentState.mounted) {
        readmeKey.currentState.refreshReadme();
      }
      if (fileKey.currentState != null && fileKey.currentState.mounted) {
        fileKey.currentState.showRefreshLoading();
      }
    });
  }
}

///底部状态实体
class BottomStatusModel {
  final String watchText;
  final String starText;
  final IconData watchIcon;
  final IconData starIcon;
  final bool star;
  final bool watch;

  BottomStatusModel(this.watchText, this.starText, this.watchIcon,
      this.starIcon, this.watch, this.star);
}

///仓库详情数据实体，包含有当前index，仓库数据，分支等等
class ReposDetailModel extends Model {
  static ReposDetailModel of(BuildContext context) =>
      ScopedModel.of<ReposDetailModel>(context);

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  String _currentBranch = "master";

  String get currentBranch => _currentBranch;

  Repository _repository = Repository.empty();

  Repository get repository => _repository;

  set repository(Repository data) {
    _repository = data;
    notifyListeners();
  }

  void setCurrentBranch(String branch) {
    _currentBranch = branch;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
