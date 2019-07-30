import 'package:flutter/material.dart';
import 'package:github_app_flutter/page/repository_detail_page.dart';
import 'package:github_app_flutter/widget/repos_header_item.dart';
import 'package:github_app_flutter/widget/sliver_header_delegate.dart';
import 'package:scoped_model/scoped_model.dart';

/// 仓库信息详情页面
/// Create by zyf
/// Date: 2019/7/26
class ReposDetailInfoPage extends StatefulWidget {
  final String username;

  final String reposName;

  ReposDetailInfoPage(this.username, this.reposName, {Key key})
      : super(key: key);
  @override
  _ReposDetailInfoPageState createState() => _ReposDetailInfoPageState();
}

class _ReposDetailInfoPageState extends State<ReposDetailInfoPage>
    with AutomaticKeepAliveClientMixin<ReposDetailInfoPage> {
  @override
  bool get wantKeepAlive => true;

  ///初始化 header 默认大小，后面动态调整
  double headerSize = 270;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScopedModelDescendant<ReposDetailModel>(
      builder: (context, child, model) {
        return Scaffold(
          body: RefreshIndicator(
              child: CustomScrollView(
                slivers: <Widget>[
                  ///头部信息
                  SliverPersistentHeader(
                      delegate: SliverHeaderDelegate(
                          minHeight: headerSize,
                          maxHeight: headerSize,
                          child: ReposHeaderItem(
                            ReposHeaderViewModel.fromHttpMap(
                                widget.username,
                                widget.reposName,
                                ReposDetailModel.of(context).repository),
                            layoutListener: (size) {
                              setState(() {
                                headerSize = size.height;
                              });
                            },
                          ))),
                ],
              ),
              onRefresh: _onRefresh),
        );
      },
    );
  }

  Future<void> _onRefresh() async {}
}
