import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qr_generator/extension/color.dart';

class QRGradientTab extends StatefulWidget {
  final Function onGenerate;

  const QRGradientTab({Key? key, required this.onGenerate}) : super(key: key);

  @override
  State<QRGradientTab> createState() => _QRGradientTabState();
}

class _QRGradientTabState extends State<QRGradientTab> {
  final TextEditingController _1stColorController = TextEditingController();
  final TextEditingController _2ndColorController = TextEditingController();

  @override
  void initState() {
    setupTextColor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gradient Color",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 30,
          ),
          TextField(
            controller: _1stColorController,
            onChanged: (text) {
              Color? inputColor = ColorExt.fromHex(text);
              setState(() {
                color1 = inputColor;
              });
            },
            decoration: InputDecoration(
                isDense: true,
                // and add this line
                contentPadding: EdgeInsets.all(15),
                labelText: 'Color HEX',
                // Set border for enabled state (default)
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(5),
                ),
                prefixIcon: Icon(
                  Icons.tag,
                  color: color1 ?? Colors.grey,
                ),
                suffixIcon: GestureDetector(
                  child: Icon(Icons.colorize_rounded,
                      color: color1 ?? Colors.grey),
                  onTap: () => pickColor(true),
                ),
                // Set border for focused state
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.blue),
                  borderRadius: BorderRadius.circular(5),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.red),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.red),
                  borderRadius: BorderRadius.circular(5),
                ),
                errorText: color1 == null ? "Invalid color" : null),
            style: TextStyle(fontSize: 12, color: color1),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: _2ndColorController,
            onChanged: (text) {
              Color? inputColor = ColorExt.fromHex(text);
              setState(() {
                color2 = inputColor;
              });
            },
            decoration: InputDecoration(
                isDense: true,
                // and add this line
                contentPadding: EdgeInsets.all(15),
                labelText: 'Color HEX',
                // Set border for enabled state (default)
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(5),
                ),
                prefixIcon: Icon(
                  Icons.tag,
                  color: color2 ?? Colors.grey,
                ),
                suffixIcon: GestureDetector(
                  child: Icon(Icons.colorize_rounded,
                      color: color2 ?? Colors.grey),
                  onTap: () => pickColor(false),
                ),
                // Set border for focused state
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.blue),
                  borderRadius: BorderRadius.circular(5),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.red),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(width: 1, color: Colors.red),
                  borderRadius: BorderRadius.circular(5),
                ),
                errorText: color2 == null ? "Invalid color" : null),
            style: TextStyle(fontSize: 12, color: color2),
          ),
          SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
                onPressed: () {
                  if (color1 != null && color2 != null) {
                    setState(() {
                      widget.onGenerate(
                          LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [color1!, color2!],
                          )
                      );
                    });
                  }
                },
                child: const Text("Generate")),
          )
        ],
      ),
    );
  }

  Color pickerColor = Colors.black;
  Color? color1 = Colors.black;
  Color? color2 = Colors.black;

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void setupTextColor() {
    _1stColorController.text = color1?.value.toRadixString(16) ?? "";
    _2ndColorController.text = color2?.value.toRadixString(16) ?? "";
  }

  void pickColor(bool isFirst) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                setState(() {
                  if (isFirst){
                    color1 = pickerColor;
                  }
                  else{
                    color2 = pickerColor;
                  }
                  setupTextColor();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
