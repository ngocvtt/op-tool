import 'dart:async';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import 'package:qr_generator/enum/qr_type.dart';

import 'pretty_qr_painter.dart';

class PrettyQr extends StatelessWidget {
  ///Widget size
  final double size;

  ///Qr code data
  final String data;

  ///Square color
  final Color? elementColor;


  ///Gradient color
  final LinearGradient? gradient;

  ///Error correct level
  final int errorCorrectLevel;

  ///Round the corners
  final bool roundEdges;

  ///Number of type generation (1 to 40 or null for auto)
  final int? typeNumber;

  final ImageProvider? image;

  //Qr Type for square or circle dot
  final QrType type;

  PrettyQr(
      {Key? key,
      this.size = 100,
      required this.data,
      this.elementColor = Colors.black,
      this.errorCorrectLevel = QrErrorCorrectLevel.M,
      this.roundEdges = false,
      this.typeNumber,
        this.gradient,
        this.type = QrType.square,
      this.image})
      : super(key: key);

  Future<ui.Image> _loadImage(BuildContext buildContext) async {
    final completer = Completer<ui.Image>();

    final stream = image!.resolve(ImageConfiguration(
      devicePixelRatio: MediaQuery.of(buildContext).devicePixelRatio,
    ));

    stream.addListener(ImageStreamListener((imageInfo, error) {
      completer.complete(imageInfo.image);
    }, onError: (dynamic error, _) {
      completer.completeError(error);
    }));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return image == null
        ? CustomPaint(
      size: Size(size, size),
      painter: PrettyQrCodePainter(
          data: data,
          errorCorrectLevel: errorCorrectLevel,
          elementColor: elementColor,
          gradient: gradient,
          roundEdges: roundEdges,
          typeNumber: typeNumber),
    )
        : FutureBuilder(
      future: _loadImage(context),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Container(
            child: CustomPaint(
              size: Size(size, size),
              painter: PrettyQrCodePainter(
                  image: snapshot.data,
                  data: data,
                  gradient: gradient,
                  errorCorrectLevel: errorCorrectLevel,
                  elementColor: elementColor,
                  roundEdges: roundEdges,
                  typeNumber: typeNumber,
                  qrType: type
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
