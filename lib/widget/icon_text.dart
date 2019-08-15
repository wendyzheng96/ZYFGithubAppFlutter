import 'package:flutter/material.dart';

/// 带图标的文本
/// Create by zyf
/// Date: 2019/7/27
class IconText extends StatelessWidget {
  final String text;
  final IconData iconData;
  final TextStyle textStyle;
  final Color iconColor;
  final double padding;
  final double iconSize;
  final VoidCallback onPressed;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double textWidth;

  IconText(this.text, this.iconData, this.textStyle,
      {this.iconColor,
      this.padding = 0.0,
      this.iconSize = 16,
      this.onPressed,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.mainAxisSize = MainAxisSize.max,
      this.textWidth = -1});

  @override
  Widget build(BuildContext context) {
    Widget showText = (textWidth == -1)
        ? Container(
            child: Text(
              text ?? "",
              style: textStyle
                  .merge(TextStyle(textBaseline: TextBaseline.alphabetic)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          )
        : Container(
            width: textWidth,
            child: Text(
              text,
              style: textStyle
                  .merge(TextStyle(textBaseline: TextBaseline.alphabetic)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
    return InkWell(
      onTap: onPressed,
      child: Container(
        child: Row(
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: iconSize,
              color: iconColor ?? Theme.of(context).primaryColor,
            ),
            Padding(padding: EdgeInsets.all(padding)),
            showText,
          ],
        ),
      ),
    );
  }
}
