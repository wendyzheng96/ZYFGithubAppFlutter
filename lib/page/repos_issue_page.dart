import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/dao/issue_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/common/utils/time_utils.dart';
import 'package:github_app_flutter/model/Issue.dart';
import 'package:github_app_flutter/widget/drop_down_filter.dart';
import 'package:github_app_flutter/widget/dynamic_list_view.dart';
import 'package:github_app_flutter/widget/icon_text.dart';

/// 仓库issue
/// Create by zyf
/// Date: 2019/7/31
class ReposIssuePage extends StatefulWidget {
  ///用户名
  final String username;

  ///仓库名
  final String reposName;

  ReposIssuePage(this.username, this.reposName);

  @override
  _ReposIssuePageState createState() => _ReposIssuePageState();
}

class _ReposIssuePageState extends State<ReposIssuePage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController inputController = TextEditingController();

  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  String _searchContent = '';

  TrendTypeModel selectType;

  int _page = 1;

  ///是否加载完成
  bool _isComplete = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    setState(() {
      selectType = issueTypes()[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        _searchWidget(),
        Expanded(
          child: DynamicListView.build(
            itemBuilder: _itemBuilder(),
            dataRequester: _dataRequester,
            initRequester: _initRequest,
            dividerColor: Theme.of(context).dividerColor,
            isLoadComplete: _isComplete,
            refreshKey: refreshKey,
          ),
        )
      ],
    );
  }

  Widget _searchWidget() => Row(
        children: <Widget>[
          PopupMenuButton<TrendTypeModel>(
            child: Container(
              width: 70,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(selectType.name),
                  Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ),
            itemBuilder: (context) {
              List<PopupMenuEntry<TrendTypeModel>> list = List();
              for (TrendTypeModel item in issueTypes()) {
                list.add(PopupMenuItem<TrendTypeModel>(
                  value: item,
                  child: Text(item.name),
                ));
              }
              return list;
            },
            onSelected: (model) {
              setState(() {
                selectType = model;
              });
              showRefreshLoading();
            },
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              decoration: BoxDecoration(
                color: Color(0xffe6e3e6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autofocus: false,
                      controller: inputController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        hintText: '请输入搜索内容',
                        hintStyle: TextStyle(
                          color: Color(ZColors.textHintValue),
                          fontSize: 14,
                        ),
                      ),
                      maxLines: 1,
                      onChanged: (String value) {
                        _searchContent = value;
                      },
                      style: TextStyle(
                        color: Color(ZColors.textPrimaryValue),
                        fontSize: 14,
                      ),
                      textInputAction: TextInputAction.search,
                      onEditingComplete: () {
                        showRefreshLoading();
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ),
                  RawMaterialButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    constraints: BoxConstraints(minWidth: 10, minHeight: 10),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () {
                      inputController.clear();
                      _searchContent = "";
                      showRefreshLoading();
                    },
                    child: Icon(
                      Icons.cancel,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              ZIcons.SEARCH,
              size: 18,
            ),
            onPressed: () {
              showRefreshLoading();
              FocusScope.of(context).requestFocus(FocusNode());
            },
            padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
          ),
        ],
      );

  Function _itemBuilder() => (List dataList, BuildContext context, int index) {
        Issue issue = dataList[index];
        String openTime = getTimeAgoStr(issue.createdAt.toLocal());
        String closeTime = getTimeAgoStr(issue.createdAt);
        return InkWell(
          child: Container(
            padding: EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.error_outline,
                    size: 16,
                    color:
                        issue.state == 'open' ? Colors.green : Colors.redAccent,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          issue.title,
                          style: TextStyle(
                            color: Color(ZColors.textPrimaryValue),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          height: 6,
                        ),
                        Text(
                          issue.state == 'open'
                              ? '#${issue.number} opened on $openTime by ${issue.user.login}'
                              : '#${issue.number} by ${issue.user.login} was closed $closeTime',
                          style: ZStyles.smallerTextSecondary,
                        )
                      ],
                    ),
                  ),
                ),
                issue.commentNum > 0
                    ? Container(
                        child: IconText(
                          '${issue.commentNum}',
                          Icons.message,
                          ZStyles.minTextHint,
                          iconColor: Color(ZColors.textHintValue),
                          padding: 1,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          onTap: () {
            NavigatorUtils.goIssueDetail(context, widget.username,
                widget.reposName, issue.number.toString());
          },
        );
      };

  showRefreshLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      refreshKey.currentState.show().then((e) {});
      return true;
    });
  }

  Future<List<Issue>> _initRequest() async {
    _page = 1;
    return await _getIssueData();
  }

  Future<List<Issue>> _dataRequester() async {
    _page++;
    return await _getIssueData();
  }

  _getIssueData() async {
    if (_searchContent == null || _searchContent.length == 0) {
      return await IssueDao.getReposIssues(
              widget.username, widget.reposName, selectType.value,
              page: _page, needDb: _page <= 1)
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
    return await IssueDao.searchReposIssue(
            _searchContent, widget.username, widget.reposName, selectType.value,
            page: _page)
        .then((res) {
      setState(() {
        _isComplete = (res.result && res.data.length < Config.PAGE_SIZE);
      });
      return res.data ?? List();
    });
  }
}

///趋势数据时间过滤
List<TrendTypeModel> issueTypes() {
  return [
    TrendTypeModel("全部", null),
    TrendTypeModel("Open", "open"),
    TrendTypeModel("Closed", "closed"),
  ];
}
