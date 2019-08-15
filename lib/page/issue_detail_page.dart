import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/dao/issue_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/common/utils/dialog_utils.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/model/Issue.dart';
import 'package:github_app_flutter/widget/common_option_widget.dart';
import 'package:github_app_flutter/widget/dynamic_list_view.dart';
import 'package:github_app_flutter/widget/issue_header_item.dart';
import 'package:github_app_flutter/widget/issue_item.dart';

/// issue详情页
/// Create by zyf
/// Date: 2019/8/2
class IssueDetailPage extends StatefulWidget {
  final String username;

  final String reposName;

  final String issueNum;

  final bool needHomeIcon;

  IssueDetailPage(this.username, this.reposName, this.issueNum,
      {this.needHomeIcon = false});

  @override
  _IssueDetailPageState createState() => _IssueDetailPageState();
}

class _IssueDetailPageState extends State<IssueDetailPage>
    with AutomaticKeepAliveClientMixin {
  ///标题栏右侧显示控制
  final OptionControl optionControl = OptionControl();

  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  ///头部信息数据是否加载成功，成功了就可以显示底部状态
  bool headerStatus = false;

  /// issue 的头部数据显示
  IssueHeaderViewModel issueHeaderModel = IssueHeaderViewModel();

  ///控制编辑时issue的title
  TextEditingController titleControl = TextEditingController();

  ///控制编辑时issue的content
  TextEditingController contentControl = TextEditingController();

  int _page = 1;

  ///是否加载完成
  bool _isComplete = false;

  @override
  bool get wantKeepAlive => true;

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
        : CommonOptionWidget(optionControl);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reposName),
        actions: <Widget>[
          rightContent,
        ],
      ),
      body: DynamicListView.build(
        itemBuilder: _itemBuilder(),
        dataRequester: _dataRequester,
        initRequester: _initRequester,
        isLoadComplete: _isComplete,
        needHeader: true,
        refreshKey: refreshKey,
      ),
      bottomNavigationBar: (!headerStatus) ? null : _getBottomWidget(context),
    );
  }

  ///刷新
  showRefreshLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      refreshKey.currentState.show().then((e) {});
      return true;
    });
  }

  _itemBuilder() => (List dataList, BuildContext context, int index) {
        if (index == 0) {
          return IssueHeaderItem(
            issueHeaderModel,
            onPressed: () {},
          );
        }
        Issue issue = dataList[index - 1];
        return IssueItem(
          IssueItemViewModel.fromMap(issue, needTitle: false),
          onLongPress: () {
            _showCommentDialog(issue);
          },
        );
      };

  Future<List<Issue>> _initRequester() async {
    _page = 1;

    ///刷新时同时更新头部信息
    await _getHeaderInfo();
    return await _getIssueComments();
  }

  Future<List<Issue>> _dataRequester() async {
    _page++;
    return await _getIssueComments();
  }

  _getIssueComments() async {
    ///刷新时同时更新头部信息
    return await IssueDao.getIssueComments(
            widget.username, widget.reposName, widget.issueNum,
            page: _page)
        .then((res) {
      if (!res.result) {
        _page--;
      }
      setState(() {
        _isComplete = (res.result && res.data.length < Config.PAGE_SIZE);
      });
      return res.data ?? List<Issue>();
    });
  }

  ///获取头部数据
  _getHeaderInfo() {
    IssueDao.getIssueDetail(widget.username, widget.reposName, widget.issueNum)
        .then((res) {
      if (res != null && res.result) {
        Issue issue = res.data;
        setState(() {
          issueHeaderModel = IssueHeaderViewModel.fromMap(issue);
          optionControl.url = issue.htmlUrl;
          headerStatus = true;
        });
      }
    });
  }

  ///获取底部控件显示
  _getBottomWidget(context) {
    TextStyle textStyle = TextStyle(
        fontSize: 14,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Theme.of(context).primaryColor);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            spreadRadius: 2,
            color: Color.fromARGB(20, 0, 60, 0),
          )
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
              child: FlatButton(
            onPressed: () {
              _replyIssue();
            },
            child: Text('回复', style: textStyle),
          )),
          _divider(),
          Expanded(
              child: FlatButton(
            onPressed: () {
              _editIssue();
            },
            child: Text('编辑', style: textStyle),
          )),
          _divider(),
          Expanded(
              child: FlatButton(
            onPressed: () {
              _closeOrOpenIssue();
            },
            child: Text(
              issueHeaderModel.state == 'closed' ? '打开' : '关闭',
              style: textStyle,
            ),
          )),
          _divider(),
          Expanded(
              child: FlatButton(
            onPressed: () {
              _lockIssue();
            },
            child: Text(
              issueHeaderModel.locked ? '解锁' : '锁定',
              style: textStyle,
            ),
          )),
        ],
      ),
    );
  }

  ///分割线
  _divider() => Container(
      width: 0.3, height: 30.0, color: Color(ZColors.subLightTextColor));

  ///回复issue
  _replyIssue() {
    titleControl = TextEditingController(text: '');
    contentControl = TextEditingController(text: '');
    String content = '';
    DialogUtils.showEditDialog(
      context,
      '回复issue',
      null,
      (replyContent) {
        content = replyContent;
      },
      onPressed: () {
        if (content == null || content.isEmpty) {
          CommonUtils.showToast('内容不能为空');
          return;
        }
        DialogUtils.showLoadingDialog(context);
        IssueDao.addIssueComment(
          widget.username,
          widget.reposName,
          widget.issueNum,
          content,
        ).then((res) {
          showRefreshLoading();
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
      needTitle: false,
      titleController: titleControl,
      contentController: contentControl,
    );
  }

  ///编辑issue
  _editIssue() {
    String title = issueHeaderModel.issueComment;
    String content = issueHeaderModel.issueDesHtml;
    titleControl = TextEditingController(text: title);
    contentControl = TextEditingController(text: content);
    DialogUtils.showEditDialog(
      context,
      '编辑issue',
      (titleValue) {
        title = titleValue;
      },
      (contentValue) {
        content = contentValue;
      },
      onPressed: () {
        if (title == null || title.isEmpty) {
          CommonUtils.showToast('标题不能为空');
          return;
        }
        if (content == null || content.isEmpty) {
          CommonUtils.showToast('内容不能为空');
          return;
        }
        DialogUtils.showLoadingDialog(context);
        IssueDao.editIssue(
          widget.username,
          widget.reposName,
          widget.issueNum,
          {"title": title, "body": content},
        ).then((res) {
          _getHeaderInfo();
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
      needTitle: true,
      titleController: titleControl,
      contentController: contentControl,
    );
  }

  ///关闭或打开issue
  _closeOrOpenIssue() {
    DialogUtils.showLoadingDialog(context);
    IssueDao.editIssue(
      widget.username,
      widget.reposName,
      widget.issueNum,
      {"state": issueHeaderModel.state == 'closed' ? 'open' : 'closed'},
    ).then((res) {
      _getHeaderInfo();
      Navigator.pop(context);
    });
  }

  ///锁定Issue
  _lockIssue() {
    DialogUtils.showLoadingDialog(context);
    IssueDao.lockIssue(widget.username, widget.reposName, widget.issueNum,
            issueHeaderModel.locked)
        .then((res) {
      _getHeaderInfo();
      Navigator.pop(context);
    });
  }

  ///issue回复操作框
  _showCommentDialog(Issue issue) {
    List<String> optionList = ['编辑', '删除', '复制'];
    DialogUtils.showListDialog(context, optionList, onTap: (index) {
      if (index == 0) {
        _editCommit(issue.id.toString(), issue.body);
      } else if (index == 1) {
        _deleteCommit(issue.id.toString());
      } else if (index == 2) {
        CommonUtils.copy(issue.body, context);
      }
    });
  }

  ///编辑issue回复
  _editCommit(String id, String content) {
    String contentData = content;
    contentControl = TextEditingController(text: contentData);
    DialogUtils.showEditDialog(
      context,
      '编辑回复',
      null,
      (value) {
        contentData = value;
      },
      onPressed: () {
        if (contentData == null || contentData.isEmpty) {
          CommonUtils.showToast('内容不能为空');
          return;
        }
        DialogUtils.showLoadingDialog(context);
        IssueDao.editComment(
          widget.username,
          widget.reposName,
          widget.issueNum,
          id,
          {"body": contentData},
        ).then((res) {
          showRefreshLoading();
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
      needTitle: false,
      contentController: contentControl,
    );
  }

  ///删除issue回复
  _deleteCommit(String id) {
    DialogUtils.showLoadingDialog(context);
    IssueDao.deleteComment(
      widget.username,
      widget.reposName,
      widget.issueNum,
      id,
    ).then((res) {
      if (!res.result) {
        CommonUtils.showToast(res.data);
      }
      Navigator.pop(context);
      showRefreshLoading();
    });
  }
}
