import 'package:flutter/material.dart';

extension ColorExt on Color {
  static Color? fromHex(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF" + hex;
    }
    if (hex.length == 8) {
      try{
        return Color(int.parse("0x$hex"));
      }
      catch (e){
        return null;
      }
    }
    return null;
  }
}