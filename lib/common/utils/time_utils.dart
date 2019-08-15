/// 时间工具类
/// Create by zyf
/// Date: 2019/7/26

const double MILLIS_LIMIT = 1000.0;

const double SECONDS_LIMIT = 60 * MILLIS_LIMIT;

const double MINUTES_LIMIT = 60 * SECONDS_LIMIT;

const double HOURS_LIMIT = 24 * MINUTES_LIMIT;

const double DAYS_LIMIT = 30 * HOURS_LIMIT;

String getDateStr(DateTime date) {
  if (date == null || date.toString() == null) {
    return "";
  } else if (date.toString().length < 10) {
    return date.toString();
  }
  return date.toString().substring(0, 10);
}

///日期格式转换
String getTimeAgoStr(DateTime date) {
  int subTime =
      DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;
  if (subTime < MILLIS_LIMIT) {
    return "刚刚";
  } else if (subTime < SECONDS_LIMIT) {
    return (subTime / MILLIS_LIMIT).round().toString() + " 秒前";
  } else if (subTime < MINUTES_LIMIT) {
    return (subTime / SECONDS_LIMIT).round().toString() + " 分钟前";
  } else if (subTime < HOURS_LIMIT) {
    return (subTime / MINUTES_LIMIT).round().toString() + " 小时前";
  } else if (subTime < DAYS_LIMIT) {
    return (subTime / HOURS_LIMIT).round().toString() + " 天前";
  } else {
    return getDateStr(date);
  }
}
