import 'package:intl/intl.dart';

class DateTimeProvider {
  static String orderCreatedDate(String createdAt) {
    final formatter = DateFormat('MMMM d');
    final dateTime = DateTime.parse(createdAt).toLocal();
    return formatter.format(dateTime);
  }

  static String orderCreatedTime(String createdAt) {
    final formatter = DateFormat('h:mm a');
    final dateTime = DateTime.parse(createdAt).toLocal();
    return formatter.format(dateTime);
  }

  static String pickupTime(String time) {
    final formatter = DateFormat('d MMM yyyy • h:mm a');
    final dateTime = DateTime.parse(time).toLocal();
    return formatter.format(dateTime);
  }
}
