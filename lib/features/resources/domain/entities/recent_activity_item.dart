import 'package:flutter/material.dart';

class RecentActivityItem {
  final int id;
  final String title;
  final String courseName;
  final String categoryLabel;
  final int academicYear;
  final String semester;
  final String typeBadge;
  final Color badgeColor;

  const RecentActivityItem({
    required this.id,
    required this.title,
    required this.courseName,
    required this.categoryLabel,
    required this.academicYear,
    required this.semester,
    required this.typeBadge,
    required this.badgeColor,
  });
}
