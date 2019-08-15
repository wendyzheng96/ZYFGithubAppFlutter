import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';

/// issue 编辑输入框
/// Create by zyf
/// Date: 2019/8/13
class IssueEditDialog extends StatefulWidget {
  final String dialogTitle;

  final ValueChanged<String> onTitleChanged;

  final ValueChanged<String> onContentChanged;

  final VoidCallback onPressed;

  final TextEditingController titleController;

  final TextEditingController contentController;

  final bool needTitle;

  IssueEditDialog(
    this.dialogTitle,
    this.onTitleChanged,
    this.onContentChanged,
    this.onPressed, {
    this.titleController,
    this.contentController,
    this.needTitle = true,
  });

  @override
  _IssueEditDialogState createState() => _IssueEditDialogState();
}

class _IssueEditDialogState extends State<IssueEditDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        ///触摸收起键盘
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.fromLTRB(50, 100, 50, 0),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          widget.dialogTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      renderTitleInput(),
                      renderContentInput(),
                      renderBottomBtn(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///标题输入框
  Widget renderTitleInput() {
    return widget.needTitle
        ? Container(
            child: TextField(
              controller: widget.titleController,
              decoration: InputDecoration(
                hintText: '请输入标题',
              ),
              onChanged: widget.onTitleChanged,
              style: TextStyle(fontSize: 14),
            ),
          )
        : Container();
  }

  ///内容输入框
  Widget renderContentInput() {
    return Container(
      height: 220,
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Color(ZColors.subTextColor),
          width: 0.5,
        ),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: TextField(
              autofocus: false,
              controller: widget.contentController,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(8),
                hintText: '请输入内容',
              ),
              maxLines: 999,
              onChanged: widget.onContentChanged,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Container(
            ///快速输入区域
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return RawMaterialButton(
                  child: Icon(
                    fastInputList[index].iconData,
                    size: 16,
                  ),
                  constraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  onPressed: () {
                    String text = fastInputList[index].content;
                    String newText = '';
                    if (widget.contentController.value != null) {
                      newText = widget.contentController.value.text;
                    }
                    newText = newText + text;
                    setState(() {
                      widget.contentController.value =
                          TextEditingValue(text: newText);
                    });
                    widget.onContentChanged?.call(newText);
                  },
                );
              },
              itemCount: fastInputList.length,
            ),
          )
        ],
      ),
    );
  }

  Widget renderBottomBtn() {
    Color color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Theme.of(context).primaryColorDark;
    return Row(
      children: <Widget>[
        Expanded(
          child: RawMaterialButton(
            child: Text(
              '取消',
              style: TextStyle(
                color: Color(ZColors.subTextColor),
                fontSize: 15,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Container(
          width: 0.5,
          height: 25,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(
          child: RawMaterialButton(
            child: Text(
              '确认',
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: widget.onPressed,
          ),
        ),
      ],
    );
  }

  var fastInputList = [
    FastInputIconModel(Icons.filter_1, "\n#"),
    FastInputIconModel(Icons.filter_2, "\n## "),
    FastInputIconModel(Icons.filter_3, "\n### "),
    FastInputIconModel(Icons.format_bold, "****"),
    FastInputIconModel(Icons.format_italic, "__"),
    FastInputIconModel(Icons.format_quote, "` `"),
    FastInputIconModel(Icons.format_shapes, " \n``` \n\n``` \n"),
    FastInputIconModel(Icons.insert_link, "[](url)"),
  ];
}

class FastInputIconModel {
  final IconData iconData;

  final String content;

  FastInputIconModel(this.iconData, this.content);
}
