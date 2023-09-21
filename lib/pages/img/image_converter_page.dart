import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ImageConverterPage extends StatefulWidget {
  const ImageConverterPage({Key? key}) : super(key: key);

  @override
  State<ImageConverterPage> createState() => _ImageConverterPageState();
}

class _ImageConverterPageState extends State<ImageConverterPage> {
  final TextEditingController _filePathController = TextEditingController();
  Uint8List? pickedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pick your .HEIC or .HEIF file"),
            const SizedBox(
              height: 20,
            ),
            TextField(
              enabled: false,
              controller: _filePathController,
              decoration: InputDecoration(
                  isDense: true,
                  // and add this line
                  contentPadding: EdgeInsets.all(15),
                  labelText: 'File path',
                  // Set border for enabled state (default)
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  // Set border for focused state
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.blue),
                    borderRadius: BorderRadius.circular(5),
                  )),
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowMultiple: false,
                      allowedExtensions: [
                        'heic',
                        'heif',
                      ],
                    );
                    if (result != null && result.paths[0] != null) {
                     setState(() {
                       _filePathController.text = result.paths[0]!;

                       File file = File(_filePathController.text);
                       pickedFile = file.readAsBytesSync();
                       if (pickedFile != null) {
                         _convertToJPEG(pickedFile!);
                       }
                     });
                    }
                  },
                  child: const Text("Pick!")),
            ),
            const SizedBox(
              height: 20,
            ),
            if (_filePathController.text.isNotEmpty)
              Center(
                child: ElevatedButton(
                    onPressed: () async {
                      if (pickedFile != null) {
                        _convertToJPEG(pickedFile!);
                      }
                    },
                    child: const Text("Convert to JPEG")),
              ),
            const SizedBox(
              height: 20,
            ),
            const Text("Please ask your friend, who use MacOS for help!"),
          ],
        ),
      ),
    );
  }

  void _convertToJPEG(Uint8List list) async{
    String imagePath = _filePathController.text.toLowerCase();
    // File file = File(imagePath);
    // pickedFile = file.readAsBytesSync();
    // final tempDir = await getApplicationDocumentsDirectory();
    // final target = '$tempDir/${DateTime.now().millisecondsSinceEpoch}.jpg';
    // final result = await FlutterImageCompress.compressAndGetFile(
    //   imagePath,
    //   target,
    //   format: CompressFormat.heic,
    //   quality: 90,
    // );
    //
    // if (result == null) {
    // // error handling here
    // }
    // else{
    //   await OpenFile.open(tempDir.path);
    // }
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 1920,
      minWidth: 1080,
      quality: 96,
      rotate: 135,
    );
    print(list.length);
    print(result.length);

  }
}
