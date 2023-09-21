import 'package:flutter/material.dart';

class LogoConfig{
  String name;
  String? path;
  Color backgroundDisplay;

  LogoConfig(this.name, this.path, {this.backgroundDisplay = Colors.transparent});
}