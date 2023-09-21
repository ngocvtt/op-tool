import 'package:flutter/material.dart';
import 'package:qr_generator/config/user_qr_config.dart';
import 'package:qr_generator/enum/qr_type.dart';

class QrTypePicker extends StatefulWidget {
  final Function onTypeChange;
  const QrTypePicker({super.key, required this.onTypeChange});

  @override
  State<QrTypePicker> createState() => _QrTypePickerState();
}

class _QrTypePickerState extends State<QrTypePicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: QrType.values.map((e) => _buildPickerCell(e)).toList(),
    );
  }

  Widget _buildPickerCell(QrType type){
    bool isPicked = UserQrConfig.currentConfig.qrType == type;
    return GestureDetector(
      onTap: (){
        setState(() {
          UserQrConfig.currentConfig.qrType = type;
        });
        widget.onTypeChange(type);
      },
      child: Container(
        width: 200,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
            color: isPicked? Colors.blue.shade50: Colors.white,
            border: Border.all(color: isPicked? Colors.blue: Colors.grey, width: isPicked? 2: 0),
            borderRadius: BorderRadius.circular(5.0)
        ),
        child: Text(type.name, style: TextStyle(color: isPicked? Colors.black: Colors.grey),),
      ),
    );
  }
}
