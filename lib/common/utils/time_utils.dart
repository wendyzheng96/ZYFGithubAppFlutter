/// 时间工具类
/// Create by zyf
/// Date: 2019/7/26

/// Outputs year as four digits
///
/// Example:
///     formatDate(DateTime(1989), [yyyy]);
///     // => 1989
const String yyyy = 'yyyy';

/// Outputs month as two digits
///
/// Example:
///     formatDate(DateTime(1989, 11), [mm]);
///     // => 11
///     formatDate(DateTime(1989, 5), [mm]);
///     // => 05
const String mm = 'mm';

/// Outputs day as two digits
///
/// Example:
///     formatDate(DateTime(1989, 2, 21), [dd]);
///     // => 21
///     formatDate(DateTime(1989, 2, 5), [dd]);
///     // => 05
const String dd = 'dd';

/// Outputs hour (0 - 11) as two digits
///
/// Example:
///     formatDate(DateTime(1989, 02, 1, 15), [hh]);
///     // => 03
const String hh = 'hh';

/// Outputs hour (0 to 23) as two digits
///
/// Example:
///     formatDate(DateTime(1989, 02, 1, 15), [HH]);
///     // => 15
const String HH = 'HH';

/// Outputs minute as two digits
///
/// Example:
///     formatDate(DateTime(1989, 02, 1, 15, 40), [nn]);
///     // => 40
///     formatDate(DateTime(1989, 02, 1, 15, 4), [nn]);
///     // => 04
const String nn = 'nn';

/// Outputs second as two digits
///
/// Example:
///     formatDate(DateTime(1989, 02, 1, 15, 40, 10), [ss]);
///     // => 10
///     formatDate(DateTime(1989, 02, 1, 15, 40, 5), [ss]);
///     // => 05
const String ss = 'ss';

/// Outputs if hour is AM or PM
///
/// Example:
///     print(formatDate(DateTime(1989, 02, 1, 5), [am]));
///     // => AM
///     print(formatDate(DateTime(1989, 02, 1, 15), [am]));
///     // => PM
const String am = 'am';

/// Outputs timezone as time offset
///
/// Example:
///
const String z = 'z';
const String Z = 'Z';

String formatDate(DateTime date, List<String> formats) {
  final sb = StringBuffer();

  for (String format in formats) {
    if (format == yyyy) {
      sb.write(_digits(date.year, 4));
    } else if (format == mm) {
      sb.write(_digits(date.month, 2));
    } else if (format == dd) {
      sb.write(_digits(date.day, 2));
    } else if (format == HH) {
      sb.write(_digits(date.hour, 2));
    } else if (format == hh) {
      int hour = date.hour % 12;
      if (hour == 0) hour = 12;
      sb.write(_digits(hour, 2));
    } else if (format == am) {
      sb.write(date.hour < 12 ? 'AM' : 'PM');
    } else if (format == nn) {
      sb.write(_digits(date.minute, 2));
    } else if (format == ss) {
      sb.write(_digits(date.second, 2));
    } else if (format == z) {
      if (date.timeZoneOffset.inMinutes == 0) {
        sb.write('Z');
      } else {
        if (date.timeZoneOffset.isNegative) {
          sb.write('-');
          sb.write(_digits((-date.timeZoneOffset.inHours) % 24, 2));
          sb.write(_digits((-date.timeZoneOffset.inMinutes) % 60, 2));
        } else {
          sb.write('+');
          sb.write(_digits(date.timeZoneOffset.inHours % 24, 2));
          sb.write(_digits(date.timeZoneOffset.inMinutes % 60, 2));
        }
      }
    } else if (format == Z) {
      sb.write(date.timeZoneName);
    } else {
      sb.write(format);
    }
  }

  return sb.toString();
}

String _digits(int value, int length) {
  String ret = '$value';
  if (ret.length < length) {
    ret = '0' * (length - ret.length) + ret;
  }
  return ret;
}

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
