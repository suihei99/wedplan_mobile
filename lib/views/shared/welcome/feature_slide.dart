import 'package:flutter/material.dart';

class WelcomeFeatureSlide {
  const WelcomeFeatureSlide({
    required this.title,
    this.subtitle,
    required this.description,
    required this.icon,
  });

  final String title;
  final String? subtitle;
  final String description;
  final IconData icon;
}
