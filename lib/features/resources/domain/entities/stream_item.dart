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
}
