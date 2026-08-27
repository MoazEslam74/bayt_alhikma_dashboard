import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String defendant;
  final String reporter;
  final String reason;
  final Timestamp timestamp;

  Report({
    required this.defendant,
    required this.reason,
    required this.reporter,
    required this.timestamp,
  });
}
