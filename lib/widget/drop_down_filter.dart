import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';

/// 下拉筛选
/// Create by zyf
/// Date: 2019/7/19

///趋势数据过滤显示item
class TrendTypeModel {
  final String name;

  final String value;

  TrendTypeModel(this.name, this.value);
}

class FilterButtonModel {
  String direction; //下拉箭头方向

  TrendTypeModel selectedModel; //已选中数据

  List<TrendTypeModel> contents; //下拉列表

  FilterCallback onSelect;

  FilterButtonModel(
      {this.direction, this.selectedModel, this.contents, this.onSelect});
}

typedef FilterCallback = void Function(TrendTypeModel selectModel);

class DropDownFilter extends StatefulWidget {
  DropDownFilter({Key key, this.buttons});

  final List<FilterButtonModel> buttons; //按钮数组 数据类型FilterButtonModel

  @override
  _DropDownFilterState createState() => _DropDownFilterState();
}

class _DropDownFilterState extends State<DropDownFilter>
    with SingleTickerProviderStateMixin {
  static const String UP = 'up';

  static const String DOWN = 'down';

  static const double FILTER_BTN_HEIGHT = 44;

  bool _isOpen = false; //筛选框是否已展开

  int _curFilterIndex = 0; //当前选择筛选按钮位置

  double _innerHeight = 0.0;

  void initButtonStatus() {
    widget.buttons.forEach((i) {
      setState(() {
        i.direction = DOWN;
      });
    });
  }

  //更新数据
  void updateData(i) {
    setState(() {
      _curFilterIndex = i;
      FilterButtonModel btn = widget.buttons[i];
      btn.direction = btn.direction == UP ? DOWN : UP;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Stack(
      //stack设置为overflow：visible之后，内部的元素中超出的部分就不能触发点击事件；所以尽量避免这种布局
      children: <Widget>[
        _contentList(widget.buttons[_curFilterIndex]),
        _filterButton(),
      ],
    ));
  }

  //筛选按钮
  Widget _filterButton() {
    return Container(
      decoration:
          BoxDecoration(color: Theme.of(context).primaryColor, boxShadow: [
        BoxShadow(
          blurRadius: 4,
          spreadRadius: 2,
          color: Color.fromARGB(50, 0, 0, 0),
        )
      ]),
      child: Row(
        children: List.generate(widget.buttons.length, (i) {
          final selectBtn = widget.buttons[i];
          return Container(
              width: MediaQuery.of(context).size.width / widget.buttons.length,
              height: FILTER_BTN_HEIGHT,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            selectBtn.selectedModel.name,
                            style: ZStyles.middleTextWhite,
                          ),
                          Icon(
                            selectBtn.direction == UP
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            size: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      onPressed: () {
                        //处理下拉列表打开时，点击别的按钮
                        if (_isOpen && i != _curFilterIndex) {
                          initButtonStatus();
                          updateData(i);
                          return;
                        }
                        updateData(i);
                        _isOpen = !_isOpen;
                      },
                    ),
                  ),
                  Container(
                    width: i == widget.buttons.length - 1 ? 0 : 1.0,
                    height: 16,
                    color: Colors.white,
                  )
                ],
              ));
        }),
      ),
    );
  }

  //筛选弹出的下拉列表
  Widget _contentList(FilterButtonModel lists) {
    if (lists.contents != null && lists.contents.length > 0) {
      setState(() {
        if (_isOpen) {
          _innerHeight = 50.0 * lists.contents.length > 300
              ? 300
              : 50.0 * lists.contents.length;
        } else {
          _innerHeight = 0;
        }
      });
      return Positioned(
          width: MediaQuery.of(context).size.width,
          top: FILTER_BTN_HEIGHT,
          left: 0,
          child: Column(
            children: <Widget>[
              AnimatedContainer(
                width: MediaQuery.of(context).size.width,
                height: _innerHeight,
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    spreadRadius: 2,
                    color: Color.fromARGB(50, 0, 0, 0),
                  )
                ]),
                curve: Curves.fastOutSlowIn,
                duration: Duration(milliseconds: 150),
                child: _innerConList(lists),
              ),
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget _innerConList(FilterButtonModel lists) {
    return ListView(
      children: List.generate(lists.contents.length, (i) {
        return FlatButton(
            onPressed: () {
              setState(() {
                FilterButtonModel model = widget.buttons[_curFilterIndex];
                model.selectedModel = model.contents[i];
                model.direction = DOWN;
                _isOpen = false;

                if (model.onSelect != null) {
                  model.onSelect(model.selectedModel);
                }
              });
            },
            highlightColor: Color(0x229bcdf0),
            splashColor: Color(0x559bcdf0),
            child: Text(
              lists.contents[i].name,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(
                      lists.selectedModel.name == lists.contents[i].name
                          ? ZColors.primaryDarkValue
                          : ZColors.textPrimaryValue)),
            ));
      }),
    );
  }
}
