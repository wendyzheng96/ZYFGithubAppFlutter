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
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black12,
          child: GestureDetector(
            ///触摸收起键盘
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Center(
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5, bottom: 15),
                        child: Text(
                          widget.dialogTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
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
      )),
    );
  }

  ///标题输入框
  Widget renderTitleInput() {
    return widget.needTitle
        ? Container(
            padding: EdgeInsets.all(5),
            child: TextField(
              controller: widget.titleController,
              decoration: InputDecoration(
                hintText: '请输入标题',
              ),
              onChanged: widget.onTitleChanged,
            ),
          )
        : Container();
  }

  ///内容输入框
  Widget renderContentInput() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Color(ZColors.subTextColor),
          width: 0.5,
        ),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
          Expanded(
              child: TextField(
            autofocus: false,
            controller: widget.contentController,
            decoration: InputDecoration(
              hintText: '请输入内容',
            ),
            maxLines: 999,
            onChanged: widget.onContentChanged,
          )),
          Container(
            ///快速输入区域
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return RawMaterialButton(
                  child: Icon(
                    FAST_INPUT_LIST[index].iconData,
                    size: 16,
                  ),
                  constraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  onPressed: () {
                    String text = FAST_INPUT_LIST[index].content;
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
              itemCount: FAST_INPUT_LIST.length,
            ),
          )
        ],
      ),
    );
  }

  Widget renderBottomBtn() {
    return Row(
      children: <Widget>[
        Expanded(
          child: RawMaterialButton(
            constraints: BoxConstraints(minWidth: 0, minHeight: 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.all(4),
            child: Text(
              '取消',
              style: TextStyle(color: Color(ZColors.subTextColor)),
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
            constraints: BoxConstraints(minWidth: 0, minHeight: 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.all(4),
            child: Text('确认'),
            onPressed: widget.onPressed,
          ),
        ),
      ],
    );
  }
}

var FAST_INPUT_LIST = [
  FastInputIconModel(Icons.filter_1, "/n#"),
  FastInputIconModel(Icons.filter_2, "\n## "),
  FastInputIconModel(Icons.filter_3, "\n### "),
  FastInputIconModel(Icons.format_bold, "****"),
  FastInputIconModel(Icons.format_italic, "__"),
  FastInputIconModel(Icons.format_quote, "` `"),
  FastInputIconModel(Icons.format_shapes, " \n``` \n\n``` \n"),
  FastInputIconModel(Icons.insert_link, "[](url)"),
];

class FastInputIconModel {
  final IconData iconData;

  final String content;

  FastInputIconModel(this.iconData, this.content);
}
