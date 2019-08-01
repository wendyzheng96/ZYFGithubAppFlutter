import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';

/// html处理
/// Create by zyf
/// Date: 2019/7/31
class HtmlUtils {
  static generateCode2HTml(String mdData,
      {String backgroundColor = ZColors.miWhiteString,
      String lang = 'java',
      userBR = true}) {
    String currentData = (mdData != null && mdData.indexOf("<code>") == -1)
        ? "<body>\n" +
            "<pre class=\"pre\">\n" +
            "<code lang='$lang'>\n" +
            mdData +
            "</code>\n" +
            "</pre>\n" +
            "</body>\n"
        : "<body>\n" +
            "<pre class=\"pre\">\n" +
            mdData +
            "</pre>\n" +
            "</body>\n";
    return generateHtml(currentData,
        backgroundColor: backgroundColor, userBR: userBR);
  }

  static generateHtml(String mdData,
      {String backgroundColor = ZColors.miWhiteString,
      userBR = true}) {
    if (mdData == null) {
      return "";
    }
    String mdDataCode = mdData;
    String regExCode =
        "<[\\s]*?code[^>]*?>[\\s\\S]*?<[\\s]*?\\/[\\s]*?code[\\s]*?>";
    String regExPre =
        "<[\\s]*?pre[^>]*?>[\\s\\S]*?<[\\s]*?\\/[\\s]*?pre[\\s]*?>";

    try {
      RegExp exp = new RegExp(regExCode);
      Iterable<Match> tags = exp.allMatches(mdData);
      for (Match m in tags) {
        String match = m.group(0).replaceAll(new RegExp("\n"), "\n\r<br>");
        mdDataCode = mdDataCode.replaceAll(m.group(0), match);
      }
    } catch (e) {
      print(e);
    }
    try {
      RegExp exp = new RegExp(regExPre);
      Iterable<Match> tags = exp.allMatches(mdDataCode);
      for (Match m in tags) {
        if (m.group(0).indexOf("<code>") < 0) {
          String match = m.group(0).replaceAll(new RegExp("\n"), "\n\r<br>");
          mdDataCode = mdDataCode.replaceAll(m.group(0), match);
        }
      }
    } catch (e) {
      print(e);
    }

    try {
      RegExp exp = new RegExp("<pre>(([\\s\\S])*?)<\/pre>");
      Iterable<Match> tags = exp.allMatches(mdDataCode);
      for (Match m in tags) {
        if (m.group(0).indexOf("<code>") < 0) {
          String match = m.group(0).replaceAll(new RegExp("\n"), "\n\r<br>");
          mdDataCode = mdDataCode.replaceAll(m.group(0), match);
        }
      }
    } catch (e) {
      print(e);
    }
    try {
      RegExp exp = new RegExp("href=\"(.*?)\"");
      Iterable<Match> tags = exp.allMatches(mdDataCode);
      for (Match m in tags) {
        String capture = m.group(0);
        if (capture.indexOf("http://") < 0 &&
            capture.indexOf("https://") < 0 &&
            capture.indexOf("#") != 0) {
          mdDataCode =
              mdDataCode.replaceAll(m.group(0), "gsygithub://" + capture);
        }
      }
    } catch (e) {
      print(e);
    }

    return generateCodeHtml(mdDataCode, false,
        backgroundColor: backgroundColor, userBR: userBR);
  }

  /// style for mdHTml
  static generateCodeHtml(mdHTML, wrap,
      {backgroundColor = Colors.white,
      String actionColor = ZColors.primaryValueString,
      userBR = true}) {
    return "<html>\n" +
        "<head>\n" +
        "<meta charset=\"utf-8\" />\n" +
        "<title></title>\n" +
        "<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/>" +
        "<link href=\"https:\/\/cdn.bootcss.com/highlight.js/9.12.0/styles/dracula.min.css\" rel=\"stylesheet\">\n" +
        "<script src=\"https:\/\/cdn.bootcss.com/highlight.js/9.12.0/highlight.min.js\"></script>  " +
        "<script>hljs.configure({'useBR': " +
        userBR.toString() +
        "});hljs.initHighlightingOnLoad();</script> " +
        "<style>" +
        "body{background: " +
        backgroundColor +
        ";}" +
        "a {color:" +
        actionColor +
        " !important;}" +
        ".highlight pre, pre {" +
        " word-wrap: " +
        (wrap ? "break-word" : "normal") +
        "; " +
        " white-space: " +
        (wrap ? "pre-wrap" : "pre") +
        "; " +
        "}" +
        "thead, tr {" +
        "background:" +
        ZColors.miWhiteString +
        ";}" +
        "td, th {" +
        "padding: 5px 10px;" +
        "font-size: 12px;" +
        "direction:hor" +
        "}" +
        ".highlight {overflow: scroll; background: " +
        ZColors.miWhiteString +
        "}" +
        "tr:nth-child(even) {" +
        "background:" +
        ZColors.primaryDarkValueString +
        ";" +
        "color:" +
        ZColors.miWhiteString +
        ";" +
        "}" +
        "tr:nth-child(odd) {" +
        "background: " +
        ZColors.miWhiteString +
        ";" +
        "color:" +
        ZColors.primaryDarkValueString +
        ";" +
        "}" +
        "th {" +
        "font-size: 14px;" +
        "color:" +
        ZColors.miWhiteString +
        ";" +
        "background:" +
        ZColors.primaryDarkValueString +
        ";" +
        "}" +
        "</style>" +
        "</head>\n" +
        "<body>\n" +
        mdHTML +
        "</body>\n" +
        "</html>";
  }

  static resolveHtmlFile(var res, String defaultLang) {
    if (res != null && res.result) {
      String startTag = "class=\"instapaper_body ";
      int startLang = res.data.indexOf(startTag);
      int endLang = res.data.indexOf("\" data-path=\"");
      String lang;
      if (startLang >= 0 && endLang >= 0) {
        String tmpLang =
            res.data.substring(startLang + startTag.length, endLang);
        if (tmpLang != null) {
          lang = formName(tmpLang.toLowerCase());
        }
      }
      if (lang == null) {
        lang = defaultLang;
      }
      if ('markdown' == lang) {
        return generateHtml(res.data);
      } else {
        return generateCode2HTml(res.data, lang: lang);
      }
    } else {
      return "<h1>" + "Not Support" + "</h1>";
    }
  }

  static formName(name) {
    switch (name) {
      case 'sh':
        return 'shell';
      case 'js':
        return 'javascript';
      case 'kt':
        return 'kotlin';
      case 'c':
      case 'cpp':
        return 'cpp';
      case 'md':
        return 'markdown';
      case 'html':
        return 'xml';
    }
    return name;
  }
}
