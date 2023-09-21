import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:qr_generator/model/logo_config.dart';

class LogoConfigCell extends StatelessWidget {
  final LogoConfig logoConfig;
  final double size;
  final double fontSize;
  final EdgeInsets? padding;
  const LogoConfigCell({super.key, required this.logoConfig, this.size = 50, this.fontSize = 9, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding?? EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: logoConfig.backgroundDisplay,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(2.0)
            ),
              child: logoConfig.path == null? Icon(Icons.image_not_supported_outlined, size: size, color: Colors.grey,): Image.asset(logoConfig.path!, height: size,)
          ),
          SizedBox(height: size/10,),
          Text(logoConfig.name, style: TextStyle(fontSize: fontSize),)
        ],
      ),
    );
  }
}
