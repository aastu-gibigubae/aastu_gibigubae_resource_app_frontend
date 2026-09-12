import 'package:flutter/material.dart';

class StreamItem {
  final int id;
  final String name;
  final String subtitle;
  final IconData icon;

  const StreamItem({
    required this.id,
    required this.name,
    this.subtitle = 'Explore Courses',
    this.icon = Icons.school_outlined,
  });

  factory StreamItem.fromJson(Map<String, dynamic> json) {
    return StreamItem(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
