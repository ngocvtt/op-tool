import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_generator/pages/qr/gradient-tab.dart';
import 'package:qr_generator/pages/qr/linear-tab.dart';
import 'package:qr_generator/pages/qr/mode.dart';
import 'package:qr_generator/qr_flutter.dart';
import 'package:qr_generator/src/pretty_qr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Generator Tool @ WTM HCMC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'QR Generator Tool @ WTM HCMC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final image = Image.asset(
    'assets/logo_square.png',
  );
  bool enableExport = false;

  GlobalKey globalKey = GlobalKey();

  ColorMode? mode;

  Color? linearColor;
  LinearGradient? gradient;

  double _currentPixelRate = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        isDense: true,
                        // and add this line
                        contentPadding: EdgeInsets.all(15),
                        labelText: 'Name',
                        // Set border for enabled state (default)
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        // Set border for focused state
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.blue),
                          borderRadius: BorderRadius.circular(5),
                        )),
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                        isDense: true,
                        // and add this line
                        contentPadding: EdgeInsets.all(15),
                        labelText: 'URL',
                        // Set border for enabled state (default)
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        // Set border for focused state
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.blue),
                          borderRadius: BorderRadius.circular(5),
                        )),
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("QR Code Result ${mode?.name?? ""}", style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(
                    height: 10,
                  ),
                  _buildQrResult(),
                  SizedBox(height: 10,),
                  Slider(
                    value: _currentPixelRate,
                    max: 20,
                    divisions: 20,
                    label: '${_currentPixelRate.round() * 200} x ${_currentPixelRate.round() * 200} px',
                    onChanged: (double value) {
                      setState(() {
                        _currentPixelRate = value;
                      });
                    },
                  ),
                  SizedBox(height: 10,),
                  Text("Image Dimensions: ${_currentPixelRate.round() * 200} x ${_currentPixelRate.round() * 200} px"),
                  ..._buildExport(),
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QRLinearTab(onGenerate: (color) {
                    //Generate with mode Linear
                    linearColor = color;
                    _handleGenerate(ColorMode.linear);
                  }),

                  QRGradientTab(onGenerate: (color) {
                    //Generate with mode Linear
                    gradient = color;
                    _handleGenerate(ColorMode.gradient);
                  })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQrResult() {
    double size = 200.0;
    Widget child = SizedBox(width: size, height: size,);
    if (_urlController.text.isNotEmpty) {
      child = SizedBox(
        width: size, height: size,
        child: RepaintBoundary(
          key: globalKey,
          child: PrettyQr(
            size: size,
            image: AssetImage('assets/logo_square.png'),
            data: _urlController.text,
            elementColor: linearColor,
            gradient: gradient,
            errorCorrectLevel: QrErrorCorrectLevel.H,
            typeNumber: null,
            roundEdges: true,
          ),
        ),
      );
    }

    return DottedBorder(
      dashPattern: [4, 3],
      strokeWidth: 2,
      borderType: BorderType.RRect,
      radius: Radius.circular(5),
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: child,
      ),
    );
  }

  void _setName(){
    if (_nameController.text.isNotEmpty){
      return;
    }

    _nameController.text = '${DateTime.now().millisecondsSinceEpoch}';
  }

  void _setMode(ColorMode colorMode){
    mode = colorMode;

    if (colorMode == ColorMode.linear){
      gradient = null;
    }
    else{
      linearColor = null;
    }
  }

  void _handleGenerate(ColorMode colorMode) {
    if (_urlController.text.isEmpty) {
      return;
    }

    setState(() {
      _setName();
      _setMode(colorMode);
      enableExport = true;
    });
  }

  List<Widget> _buildExport() {
    if (enableExport) {
      return [
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
            onPressed: () {
              _captureAndSharePng();
            },
            child: const Text("Export"))
      ];
    }

    return [];
  }

  Future<void> _captureAndSharePng() async {
    try {
      RenderObject? boundary = globalKey.currentContext?.findRenderObject();
      var image =
          await (boundary as RenderRepaintBoundary).toImage(pixelRatio: _currentPixelRate);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List? pngBytes = byteData?.buffer.asUint8List();

      final tempDir = await getApplicationDocumentsDirectory();
      final file = await File(
              '${tempDir.path}/${_nameController.text}.png')
          .create();
      await file.writeAsBytes(pngBytes!);

      print(file.path);
      await OpenFile.open(tempDir.path);
    } catch (e) {
      print(e.toString());
    }
  }
}
