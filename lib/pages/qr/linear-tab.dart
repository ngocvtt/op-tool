import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qr_generator/extension/color.dart';

class QRLinearTab extends StatefulWidget {
  final Function onGenerate;

  const QRLinearTab({Key? key, required this.onGenerate}) : super(key: key);

  @override
  State<QRLinearTab> createState() => _QRLinearTabState();
}

class _QRLinearTabState extends State<QRLinearTab> {
  final TextEditingController _colorController = TextEditingController();

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
            "Linear Color",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 30,
          ),
          TextField(
            controller: _colorController,
            onChanged: (text) {
              Color? inputColor = ColorExt.fromHex(text);
              setState(() {
                currentColor = inputColor;
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
                  color: currentColor ?? Colors.grey,
                ),
                suffixIcon: GestureDetector(
                  child: Icon(Icons.colorize_rounded,
                      color: currentColor ?? Colors.grey),
                  onTap: () => pickColor(),
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
                errorText: currentColor == null ? "Invalid color" : null),
            style: TextStyle(fontSize: 12, color: currentColor),
          ),
          SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
                onPressed: () {
                  if (currentColor != null) {
                    setState(() {
                      widget.onGenerate(currentColor);
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
  Color? currentColor = Colors.black;

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void setupTextColor() {
    _colorController.text = currentColor?.value.toRadixString(16) ?? "";
  }

  void pickColor() {
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
                  currentColor = pickerColor;
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
