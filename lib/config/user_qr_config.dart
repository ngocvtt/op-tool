import 'package:flutter/material.dart';
import 'package:qr_generator/model/qr_config.dart';

import '../model/logo_config.dart';

class UserQrConfig{
  static  List<LogoConfig> logoOptions = [
    LogoConfig("None", null),
    LogoConfig("original_logo", "assets/wtm.png"),
    LogoConfig("logo_black", "assets/wtm-black.png"),
    LogoConfig("logo_white", "assets/wtm-white.png", backgroundDisplay: Colors.black),
  ];

  static QrConfig currentConfig = QrConfig(logoOptions[1]);
}