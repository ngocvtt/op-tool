import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_generator/config/user_qr_config.dart';
import 'package:qr_generator/model/logo_config.dart';
import 'package:qr_generator/model/qr_config.dart';
import 'package:qr_generator/pages/qr/logo-picker.dart';
import 'package:qr_generator/pages/qr/qr_type_picker.dart';

import 'logo-config-cell.dart';

class QrConfigTab extends StatefulWidget {
  final Function onConfigChanged;
  const QrConfigTab({super.key, required this.onConfigChanged});

  @override
  State<QrConfigTab> createState() => _QrConfigTabState();
}

class _QrConfigTabState extends State<QrConfigTab> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Configuration",
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 20,),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Logo", style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),
                  LogoConfigCell(logoConfig: UserQrConfig.currentConfig.logoConfig, padding: EdgeInsets.zero,),
                  SizedBox(height: 10,),
                  ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return LogoPicker(logos: UserQrConfig.logoOptions, initialLogo: UserQrConfig.currentConfig.logoConfig, onLogoPicked: (logo){
                              setState(() {
                                UserQrConfig.currentConfig.logoConfig = logo;
                              });
                              widget.onConfigChanged(UserQrConfig.currentConfig);
                            },);
                          },
                        );
                      },
                      child: const Text("Choose")),
                ],
              ),
              SizedBox(width: 20,),
              VerticalDivider(width: 1, color: Colors.grey, thickness: 1, indent: 20),
              SizedBox(width: 20,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Qr Type", style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    QrTypePicker(
                      onTypeChange: (type){
                        widget.onConfigChanged(UserQrConfig.currentConfig);
                      },
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
              ),

            ],
          ),
        )
      ]),
    );
  }
}
