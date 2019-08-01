import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:share/share.dart';

/// 更多公共选项
/// Create by zyf
/// Date: 2019/8/1
class CommonOptionWidget extends StatelessWidget {
  final List<OptionModel> otherList;

  final OptionControl control;

  CommonOptionWidget(this.control, {this.otherList});

  @override
  Widget build(BuildContext context) {
    List<OptionModel> list = [
      OptionModel('浏览器打开', 'browser', (model) {
        CommonUtils.launchOutURL(control.url, context);
      }),
      OptionModel('复制链接', 'copy', (model) {
        CommonUtils.copy(control.url ?? "", context);
      }),
      OptionModel('分享', 'share', (model) {
        Share.share('分享自GitHubFlutter：' + control.url ?? "");
      }),
    ];
    if (otherList != null && otherList.length > 0) {
      list.addAll(otherList);
    }
    return _renderHeaderPopItem(list);
  }

  _renderHeaderPopItem(List<OptionModel> list) {
    return PopupMenuButton<OptionModel>(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Icon(Icons.more_vert),
      ),
      itemBuilder: (BuildContext context) {
        return _renderHeaderPopItemChild(list);
      },
      onSelected: (model) {
        model.selected(model);
      },
    );
  }

  _renderHeaderPopItemChild(List<OptionModel> data) {
    List<PopupMenuEntry<OptionModel>> list = List();
    for (OptionModel item in data) {
      list.add(PopupMenuItem<OptionModel>(
        value: item,
        child: Text(item.name),
      ));
    }
    return list;
  }
}

class OptionControl {
  String url = ZConstant.app_default_share_url;
}

class OptionModel {
  final String name;
  final String value;
  final PopupMenuItemSelected<OptionModel> selected;

  OptionModel(this.name, this.value, this.selected);
}
