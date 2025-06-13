import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PreparedDates {
  final String singleDate;
  final String firstDate;
  final String lastDate;

  const PreparedDates({
    required this.singleDate,
    required this.firstDate,
    required this.lastDate,
  });
}

class DateFormatter {
  static PreparedDates formatDates(Map<String, dynamic> data) {
    final displayFormatter = DateFormat("dd MMMM yyyy", "ms_MY");

    String formattedSingleDate = "";
    String formattedFirstDate = "";
    String formattedLastDate = "";

    try {
      final singleDateTimestamp = data['tarikh'] ?? data['date'];
      if (singleDateTimestamp is Timestamp) {
        formattedSingleDate = displayFormatter.format(singleDateTimestamp.toDate());
      }

      final firstDate = data['firstDate'];
      if (firstDate is Timestamp) {
        formattedFirstDate = displayFormatter.format(firstDate.toDate());
      } else if (firstDate is DateTime) {
        formattedFirstDate = displayFormatter.format(firstDate);
      }

      final lastDate = data['lastDate'];
      if (lastDate is Timestamp) {
        formattedLastDate = displayFormatter.format(lastDate.toDate());
      } else if (lastDate is DateTime) {
        formattedLastDate = displayFormatter.format(lastDate);
      }

      if (formattedFirstDate.isNotEmpty && formattedFirstDate == formattedLastDate) {
        formattedLastDate = "";
      }
    } catch (e) {
      print("Error formatting dates: $e");
      formattedSingleDate = "Ralat Tarikh";
      formattedFirstDate = "Ralat Tarikh";
      formattedLastDate = "";
    }

    return PreparedDates(
      singleDate: formattedSingleDate,
      firstDate: formattedFirstDate,
      lastDate: formattedLastDate,
    );
  }
}
