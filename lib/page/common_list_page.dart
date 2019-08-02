import 'package:flutter/material.dart';
import 'package:github_app_flutter/widget/dynamic_list_view.dart';

/// 通用list页
/// Create by zyf
/// Date: 2019/7/29
class CommonListPage extends StatefulWidget {
  final String userName;

  final String reposName;

  final String showType;

  final String dataType;

  final String title;

  CommonListPage(this.title, this.showType, this.dataType,
      {this.userName, this.reposName});

  @override
  _CommonListPageState createState() => _CommonListPageState();
}

class _CommonListPageState extends State<CommonListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Container(
          color: Colors.white,
          child: DynamicListView.build(
            itemBuilder: _itemBuilder(),
            dataRequester: _dataRequester,
            initRequester: _initRequester,
          ),
        ));
  }

  Future<List<String>> _initRequester() async {
    return <String>['1', '2'];
  }

  Future<List<String>> _dataRequester() async {
    return <String>['1', '2'];
  }

  Function _itemBuilder() => (List dataList, BuildContext context, int index) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Text('$index'),
    );
  };
}
