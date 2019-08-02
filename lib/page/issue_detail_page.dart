import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/dao/issue_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
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
  final OptionControl titleOptionControl = OptionControl();

  ///头部信息数据是否加载成功，成功了就可以显示底部状态
  bool headerStatus = false;

  /// issue 的头部数据显示
  IssueHeaderViewModel issueHeaderModel = IssueHeaderViewModel();

  int _page = 1;

  ///是否加载完成
  bool _isComplete = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget rightContent =
        (widget.needHomeIcon) ? null : CommonOptionWidget(titleOptionControl);
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
      ),
      bottomNavigationBar: (!headerStatus) ? null : _getBottomWidget(),
    );
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
            page: _page, needDb: _page <= 1)
        .then((res) {
      if(!res.result) {
        _page--;
      }
      setState(() {
        _isComplete = (res.result && res.data.length < Config.PAGE_SIZE);
      });
      return res.data ?? List();
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
          titleOptionControl.url = issue.htmlUrl;
          headerStatus = true;
        });
      }
    });
  }

  ///获取底部控件显示
  _getBottomWidget() => Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            blurRadius: 3,
            spreadRadius: 2,
            color: Color.fromARGB(20, 0, 60, 0),
          )
        ]),
        child: Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                onPressed: () {},
                child: Text(
                  '回复',
                  style: ZStyles.smallMainText,
                ),
              ),
            ),
            _divider(),
            Expanded(
              child: FlatButton(
                onPressed: () {},
                child: Text(
                  '编辑',
                  style: ZStyles.smallMainText,
                ),
              ),
            ),
            _divider(),
            Expanded(
              child: FlatButton(
                onPressed: () {},
                child: Text(
                  '关闭',
                  style: ZStyles.smallMainText,
                ),
              ),
            ),
            _divider(),
            Expanded(
              child: FlatButton(
                onPressed: () {},
                child: Text(
                  '锁定',
                  style: ZStyles.smallMainText,
                ),
              ),
            ),
          ],
        ),
      );

  _divider() => Container(
        width: 0.3,
        height: 30.0,
        color: Color(ZColors.subLightTextColor),
      );
}
