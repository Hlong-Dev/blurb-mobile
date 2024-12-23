import 'package:timeago/timeago.dart' as timeago;

// Hàm chuyển đổi ngày giờ
String getTimeAgo(String createdAt) {
  DateTime parsedDate = DateTime.parse(createdAt);
  return timeago.format(parsedDate, locale: 'vi'); // Chỉ định sử dụng tiếng Việt
}
