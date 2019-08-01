import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';

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

  String _searchContent = '';

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
                child: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xffe6e3e6),
                borderRadius: BorderRadius.circular(4),
              ),
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
              ),
            )),
            RawMaterialButton(
              constraints: BoxConstraints(minWidth: 0, minHeight: 0),
              padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
              child: Text(
                '搜索',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {},
            ),
          ],
        )
      ],
    );
  }
}
