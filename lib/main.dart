import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_generator/pages/qr/mode.dart';
import 'package:qr_generator/pages/qr/qr_main_page.dart';
import 'package:qr_generator/pages/shorten_url/shorten_url_page.dart';
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
      title: 'Internal Tool @ WTM HCMC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Internal Tool @ WTM HCMC'),

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

  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    // const Text(
    //   'Index 0: Home',
    //   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    // ),
   const QrMainPage(),

    ShortenUrlPage(),
  ];

  String currentTitle = "QR Generator";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Center(child: Text('Happy doing deadlines!\nHope this tool helps!', style: TextStyle(color: Colors.white),)),
            ),
            // ListTile(
            //   title: const Text('Home'),
            //   selected: _selectedIndex == 0,
            //   onTap: () {
            //     // Update the state of the app
            //     _onItemTapped(0);
            //     // Then close the drawer
            //     Navigator.pop(context);
            //   },
            // ),
            ListTile(
              title: const Text('QR Generator'),
              selected: _selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                _onItemTapped(0, "QR Generator");
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Shorten Url (via tinyUrl)'),
              selected: _selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                _onItemTapped(1, "Shorten Url (via tinyUrl)");
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _widgetOptions[_selectedIndex],
    );
  }

  void _onItemTapped(int index, String title) {
    setState(() {
      _selectedIndex = index;
      currentTitle = title;
    });
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
