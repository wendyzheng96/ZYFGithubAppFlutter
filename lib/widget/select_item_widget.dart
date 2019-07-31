import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';

/// 选择按钮
/// Create by zyf
/// Date: 2019/7/30

typedef void SelectItemChanged<int>(int value);

class SelectItemWidget extends StatefulWidget implements PreferredSizeWidget {
  final List<String> itemNames;

  final SelectItemChanged selectItemChanged;

  final RoundedRectangleBorder shape;

  final double elevation;

  final double height;

  final EdgeInsets margin;

  SelectItemWidget(
    this.itemNames,
    this.selectItemChanged, {
    this.elevation = 5.0,
    this.height = 56.0,
    this.shape,
    this.margin = EdgeInsets.zero,
  });

  @override
  Size get preferredSize {
    return Size.fromHeight(height);
  }

  @override
  _SelectItemWidgetState createState() => _SelectItemWidgetState();
}

class _SelectItemWidgetState extends State<SelectItemWidget> {
  int selectIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.elevation,
      margin: widget.margin,
      color: Theme.of(context).primaryColor,
      shape: widget.shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
      child: Row(
        children: _renderList(),
      ),
    );
  }

  _renderList() {
    List<Widget> list = List();
    for (int i = 0; i < widget.itemNames.length; i++) {
      if (i == widget.itemNames.length - 1) {
        list.add(_renderItem(widget.itemNames[i], i));
      } else {
        list.add(_renderItem(widget.itemNames[i], i));
        list.add(new Container(
            width: 1.0, height: 20.0, color: Color(ZColors.miWhite)));
      }
    }
    return list;
  }

  _renderItem(String name, int index) {
    var color = Color(index == selectIndex
        ? ZColors.textColorWhite
        : ZColors.miWhite);
    return Expanded(
      child: RawMaterialButton(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
          child: Text(
            name,
            style: TextStyle(color: color, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            if (selectIndex != index) {
              widget.selectItemChanged?.call(index);
            }
            setState(() {
              selectIndex = index;
            });
          }),
    );
  }
}
