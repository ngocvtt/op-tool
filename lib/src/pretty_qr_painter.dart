import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import 'package:qr_generator/enum/qr_type.dart';

import '../qr_flutter.dart';

class PrettyQrCodePainter extends CustomPainter {
  final String data;
  final Color? elementColor;
  final int errorCorrectLevel;
  final bool roundEdges;
  ui.Image? image;
  late QrCode _qrCode;
  late QrImage _qrImage;
  int deletePixelCount = 0;
  final LinearGradient? gradient;
  final QrType qrType;

  PrettyQrCodePainter({
    required this.data,
    this.elementColor = Colors.black,
    this.errorCorrectLevel = QrErrorCorrectLevel.M,
    this.roundEdges = false,
    this.image,
    this.gradient,
    int? typeNumber,
    this.qrType = QrType.square,
  }) {
    if (typeNumber == null) {
      _qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: errorCorrectLevel,
      );
    } else {
      _qrCode = QrCode(typeNumber, errorCorrectLevel);
      _qrCode.addData(data);
    }

    _qrImage = QrImage(_qrCode);
  }

  @override
  paint(Canvas canvas, Size size) {
    if (image != null) {
      if (this._qrImage.typeNumber <= 2) {
        deletePixelCount = this._qrImage.typeNumber + 7;
      } else if (this._qrImage.typeNumber <= 4) {
        deletePixelCount = this._qrImage.typeNumber + 8;
      } else {
        deletePixelCount = this._qrImage.typeNumber + 9;
      }

      var imageSize = Size(image!.width.toDouble(), image!.height.toDouble());

      var src = Alignment.center.inscribe(
          imageSize,
          Rect.fromLTWH(
              0, 0, image!.width.toDouble(), image!.height.toDouble()));

      var dst = Alignment.center.inscribe(
          Size(size.height / 4, size.height / 4),
          Rect.fromLTWH(size.width / 3, size.height / 3, size.height / 3,
              size.height / 3));

      canvas.drawImageRect(image!, src, dst, Paint());
    }

    roundEdges ? _paintRound(canvas, size) : _paintDefault(canvas, size);
  }

  void _paintRound(Canvas canvas, Size size) {



    var _paint = Paint();

    if (gradient != null) {
      _paint.shader =
          gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    }
    else{
      _paint
        ..style = PaintingStyle.fill
        ..color = elementColor!
        ..isAntiAlias = true;
    }

    var _paintBackground = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white
      ..isAntiAlias = true;

    List<List?> matrix = []..length = _qrImage.moduleCount + 2;
    for (var i = 0; i < _qrImage.moduleCount + 2; i++) {
      matrix[i] = []..length = _qrImage.moduleCount + 2;
    }

    for (int x = 0; x < _qrImage.moduleCount + 2; x++) {
      for (int y = 0; y < _qrImage.moduleCount + 2; y++) {
        matrix[x]![y] = false;
      }
    }

    for (int x = 0; x < _qrImage.moduleCount; x++) {
      for (int y = 0; y < _qrImage.moduleCount; y++) {
        if (image != null &&
            x >= deletePixelCount &&
            y >= deletePixelCount &&
            x < _qrImage.moduleCount - deletePixelCount &&
            y < _qrImage.moduleCount - deletePixelCount) {
          matrix[y + 1]![x + 1] = false;
          continue;
        }

        if (_qrImage.isDark(y, x)) {
          matrix[y + 1]![x + 1] = true;
        } else {
          matrix[y + 1]![x + 1] = false;
        }
      }
    }


    int eyeDots = countEyesDot(matrix);

    double pixelSize = size.width / _qrImage.moduleCount;

    for (int x = 0; x < _qrImage.moduleCount; x++) {
      for (int y = 0; y < _qrImage.moduleCount; y++) {
        bool checkEye = isShapeEye(x, y, eyeDots);
        if (checkEye || matrix[y + 1]![x + 1]) {
          if (checkEye){
            final Rect squareRect =
            Rect.fromLTWH((x - 1) * pixelSize, (y - 1) * pixelSize , pixelSize, pixelSize);
            _setShapeEyes(x, y, squareRect, _paint, matrix, canvas,
                _qrImage.moduleCount);
          }
          else
            {
              final Rect squareRect =
              Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize);
              _setShape(x + 1, y + 1, squareRect, _paint, matrix, canvas,
                  _qrImage.moduleCount);
            }

        } else {
          _setShapeInner(
              x + 1, y + 1, _paint, matrix, canvas, pixelSize);
        }

      }
    }

    int max = _qrImage.moduleCount;
    for (int x = 1; x <= eyeDots; x++){
      if (isShapeEye(x, max, eyeDots)){
        final Rect squareRect =
        Rect.fromLTWH((x - 1) * pixelSize, (max  -1) * pixelSize , pixelSize, pixelSize);
        _setShapeEyes(x, max, squareRect, _paint, matrix, canvas,
            max);
      }
    }

    for (int y = 1; y <= eyeDots; y++){
      if (isShapeEye(max, y, eyeDots)){
        final Rect squareRect =
        Rect.fromLTWH((max - 1) * pixelSize, (y  -1) * pixelSize , pixelSize, pixelSize);
        _setShapeEyes(max, y, squareRect, _paint, matrix, canvas,
            max);
      }
    }
  }

  void _drawCurve(Offset p1, Offset p2, Offset p3, Canvas canvas) {
    Path path = Path();

    path.moveTo(p1.dx, p1.dy);
    path.quadraticBezierTo(p2.dx, p2.dy, p3.dx, p3.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p1.dx, p1.dy);
    path.close();


    var _paint = Paint();
    if (gradient != null) {
      _paint.shader = gradient!.createShader(const Rect.fromLTWH(0, 0, 200, 200));
      _paint.blendMode = BlendMode.values[12];

    }
    else{
      _paint
        ..style = PaintingStyle.fill
        ..color = elementColor!;
    }

    canvas.drawPath(
        path,
        _paint);
  }

  void _setShapeInner(
      int x, int y, Paint paint, List matrix, Canvas canvas, double pixelSize) {
    double widthY = pixelSize * (y - 1);
    double heightX = pixelSize * (x - 1);

    double temp = 0;

    //bottom right check
    if (matrix[y + 1][x] && matrix[y][x + 1] && matrix[y + 1][x + 1]) {
      Offset p1 =
          Offset(heightX + pixelSize - (temp * pixelSize), widthY + pixelSize);
      Offset p2 = Offset(heightX + pixelSize, widthY + pixelSize);
      Offset p3 =
          Offset(heightX + pixelSize, widthY + pixelSize - (temp * pixelSize));

      _drawCurve(p1, p2, p3, canvas);
    }

    //top left check
    if (matrix[y - 1][x] && matrix[y][x - 1] && matrix[y - 1][x - 1]) {
      Offset p1 = Offset(heightX, widthY + (temp * pixelSize));
      Offset p2 = Offset(heightX, widthY);
      Offset p3 = Offset(heightX + (temp * pixelSize), widthY);

      _drawCurve(p1, p2, p3, canvas);
    }

    //bottom left check
    if (matrix[y + 1][x] && matrix[y][x - 1] && matrix[y + 1][x - 1]) {
      Offset p1 = Offset(heightX, widthY + pixelSize - (temp * pixelSize));
      Offset p2 = Offset(heightX, widthY + pixelSize);
      Offset p3 = Offset(heightX + (temp * pixelSize), widthY + pixelSize);

      _drawCurve(p1, p2, p3, canvas);
    }

    //top right check
    if (matrix[y - 1][x] && matrix[y][x + 1] && matrix[y - 1][x + 1]) {
      Offset p1 = Offset(heightX + pixelSize - (temp * pixelSize), widthY);
      Offset p2 = Offset(heightX + pixelSize, widthY);
      Offset p3 = Offset(heightX + pixelSize, widthY + (temp * pixelSize));

      _drawCurve(p1, p2, p3, canvas);
    }
  }

  //Round the corners and paint it
  void _setShape(int x, int y, Rect squareRect, Paint paint, List matrix,
      Canvas canvas, int n) {
    bool bottomRight = false;
    bool bottomLeft = false;
    bool topRight = false;
    bool topLeft = false;

    //if it is dot (arount an empty place)
    if (!matrix[y + 1][x] &&
        !matrix[y][x + 1] &&
        !matrix[y - 1][x] &&
        !matrix[y][x - 1]) {
      if (qrType == QrType.circle){
        canvas.drawRRect(
            RRect.fromRectAndCorners( squareRect,
                bottomLeft: Radius.circular(6.0),
                bottomRight: Radius.circular(6.0),
                topLeft: Radius.circular(6.0),
                topRight: Radius.circular(6.0)),
            paint);
      }
      else{
        canvas.drawRRect(
            RRect.fromRectAndCorners(squareRect,
                bottomRight: Radius.circular(2.5),
                bottomLeft: Radius.circular(2.5),
                topLeft: Radius.circular(2.5),
                topRight: Radius.circular(2.5)),
            paint);
      }
      return;
    }

    //bottom right check
    if (!matrix[y + 1][x] && !matrix[y][x + 1]) {
      bottomRight = true;
    }

    //top left check
    if (!matrix[y - 1][x] && !matrix[y][x - 1]) {
      topLeft = true;
    }

    //bottom left check
    if (!matrix[y + 1][x] && !matrix[y][x - 1]) {
      bottomLeft = true;
    }

    //top right check
    if (!matrix[y - 1][x] && !matrix[y][x + 1]) {
      topRight = true;
    }



    if (qrType == QrType.circle){
      canvas.drawRRect(
          RRect.fromRectAndCorners(
            squareRect,
            bottomLeft: Radius.circular(6.0),
            bottomRight: Radius.circular(6.0),
            topLeft: Radius.circular(6.0),
            topRight: Radius.circular(6.0),
            // bottomRight: bottomRight ? Radius.circular(6.0) : Radius.zero,
            // bottomLeft: bottomLeft ? Radius.circular(6.0) : Radius.zero,
            // topLeft: topLeft ? Radius.circular(6.0) : Radius.zero,
            // topRight: topRight ? Radius.circular(6.0) : Radius.zero,
          ),
          paint);
    }
    else{
      canvas.drawRRect(
          RRect.fromRectAndCorners(
            squareRect,
            bottomRight: bottomRight ? Radius.circular(6.0) : Radius.zero,
            bottomLeft: bottomLeft ? Radius.circular(6.0) : Radius.zero,
            topLeft: topLeft ? Radius.circular(6.0) : Radius.zero,
            topRight: topRight ? Radius.circular(6.0) : Radius.zero,
          ),
          paint);
    }


    //if it is dot (arount an empty place)
    if (!bottomLeft && !bottomRight && !topLeft && !topRight) {

      if (qrType == QrType.circle){
        canvas.drawRRect(
            RRect.fromRectAndCorners(squareRect,
                bottomLeft: Radius.circular(6.0),
                bottomRight: Radius.circular(6.0),
                topLeft: Radius.circular(6.0),
                topRight: Radius.circular(6.0)),
            paint);
      }
      else{
        canvas.drawRect(squareRect, paint);
      }
    }

  }

  void _paintDefault(Canvas canvas, Size size) {

    var _paint = Paint();
    if (gradient != null){
      _paint.shader = gradient!
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      _paint.blendMode = BlendMode.values[12];
    }else{
      _paint
        ..style = PaintingStyle.fill
        ..color = elementColor!
        ..isAntiAlias = true;
    }


    ///size of point
    double pixelSize = size.width / _qrImage.moduleCount;

    for (int x = 0; x < _qrImage.moduleCount; x++) {
      for (int y = 0; y < _qrImage.moduleCount; y++) {
        if (image != null &&
            x >= deletePixelCount &&
            y >= deletePixelCount &&
            x < _qrImage.moduleCount - deletePixelCount &&
            y < _qrImage.moduleCount - deletePixelCount) continue;

        if (_qrImage.isDark(y, x)) {
          canvas.drawRect(
              Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
              _paint);
        }
      }
    }
  }


  int countEyesDot(List matrix){

    int x = 1;
    int y = 1;
    while(matrix[x][y] && y < _qrImage.moduleCount){
      y++;
    }

    return y -1;
  }

  void _setShapeInnerEyes(
      int x, int y, Paint paint, List matrix, Canvas canvas, double pixelSize) {
    double widthY = pixelSize * (y - 1);
    double heightX = pixelSize * (x - 1);

    //bottom right check
    if (matrix[y + 1][x] && matrix[y][x + 1] && matrix[y + 1][x + 1]) {
      Offset p1 =
      Offset(heightX + pixelSize - (0.25 * pixelSize), widthY + pixelSize);
      Offset p2 = Offset(heightX + pixelSize, widthY + pixelSize);
      Offset p3 =
      Offset(heightX + pixelSize, widthY + pixelSize - (0.25 * pixelSize));

      _drawCurve(p1, p2, p3, canvas);
    }

    //top left check
    if (matrix[y - 1][x] && matrix[y][x - 1] && matrix[y - 1][x - 1]) {
      Offset p1 = Offset(heightX, widthY + (0.25 * pixelSize));
      Offset p2 = Offset(heightX, widthY);
      Offset p3 = Offset(heightX + (0.25 * pixelSize), widthY);

      _drawCurve(p1, p2, p3, canvas);
    }

    //bottom left check
    if (matrix[y + 1][x] && matrix[y][x - 1] && matrix[y + 1][x - 1]) {
      Offset p1 = Offset(heightX, widthY + pixelSize - (0.25 * pixelSize));
      Offset p2 = Offset(heightX, widthY + pixelSize);
      Offset p3 = Offset(heightX + (0.25 * pixelSize), widthY + pixelSize);

      _drawCurve(p1, p2, p3, canvas);
    }

    //top right check
    if (matrix[y - 1][x] && matrix[y][x + 1] && matrix[y - 1][x + 1]) {
      Offset p1 = Offset(heightX + pixelSize - (0.25 * pixelSize), widthY);
      Offset p2 = Offset(heightX + pixelSize, widthY);
      Offset p3 = Offset(heightX + pixelSize, widthY + (0.25 * pixelSize));

      _drawCurve(p1, p2, p3, canvas);
    }
  }

  //Round the corners and paint it
  void _setShapeEyes(int x, int y, Rect squareRect, Paint paint, List matrix,
      Canvas canvas, int n) {
    bool bottomRight = false;
    bool bottomLeft = false;
    bool topRight = false;
    bool topLeft = false;


    int max = _qrImage.moduleCount;
    //if it is dot (arount an empty place)
    if (!matrix[y + 1][x] &&
        !matrix[y][x + 1] &&
        !matrix[y - 1][x] &&
        !matrix[y][x - 1]) {
      canvas.drawRRect(
          RRect.fromRectAndCorners(squareRect,
              bottomRight: Radius.circular(2.5),
              bottomLeft: Radius.circular(2.5),
              topLeft: Radius.circular(2.5),
              topRight: Radius.circular(2.5)),
          paint);
      return;
    }

    //bottom right check
    if (!matrix[y + 1][x] && !matrix[y][x + 1]) {
      bottomRight = true;
    }

    //top left check
    if (!matrix[y - 1][x] && !matrix[y][x - 1]) {
      topLeft = true;
    }

    //bottom left check
    if (!matrix[y + 1][x] && !matrix[y][x - 1]) {
      bottomLeft = true;
    }

    //top right check
    if (!matrix[y - 1][x] && !matrix[y][x + 1]) {
      topRight = true;
    }

    canvas.drawRRect(
        RRect.fromRectAndCorners(
          squareRect,
          bottomRight: bottomRight ? Radius.circular(6.0) : Radius.zero,
          bottomLeft: bottomLeft ? Radius.circular(6.0) : Radius.zero,
          topLeft: topLeft ? Radius.circular(6.0) : Radius.zero,
          topRight: topRight ? Radius.circular(6.0) : Radius.zero,
        ),
        paint);

    //if it is dot (arount an empty place)
    if (!bottomLeft && !bottomRight && !topLeft && !topRight) {
      canvas.drawRect(squareRect, paint);
    }
  }

  bool isShapeEye(int x, int y, int eyeDots){
    //top left
    if (x >= 1 && x <= eyeDots && 1 <= y && y <= eyeDots) {
      if ((x == 2 || x == eyeDots - 1) && y != 1 && y != eyeDots)
        return false;
      if ((y == 2 || y == eyeDots - 1) && x != 1 && x != eyeDots) {
        return false;
      }
      return true;
    }
    //
    // if (y == eyeDots && 1 <= x && x <= eyeDots) {
    //   return true;
    // }
    // if (x == eyeDots && 1 <= y && y <= eyeDots) {
    //   return true;
    // }

    //bottom left
    if (x >= 1 && x <= eyeDots &&  _qrImage.moduleCount - eyeDots + 1 <= y && y <= _qrImage.moduleCount) {
      if ((x == 2 || x == eyeDots - 1) && y != _qrImage.moduleCount - eyeDots + 1 && y != _qrImage.moduleCount)
        return false;
      if ((y ==  _qrImage.moduleCount - eyeDots + 2  || y == _qrImage.moduleCount - 1) && x != 1 && x != eyeDots) {
        return false;
      }
      return true;
    }
    //
    // if (x == 1 && _qrImage.moduleCount - eyeDots + 1 <= y && y <= _qrImage.moduleCount + 1) {
    //   return true;
    // }
    // if (x == eyeDots &&  _qrImage.moduleCount - eyeDots + 1 <= y && y <= _qrImage.moduleCount + 1) {
    //   return true;
    // }
    // if (y == _qrImage.moduleCount - eyeDots + 1 && 1 <= x && x <= eyeDots) {
    //   return true;
    // }
    // if (y == _qrImage.moduleCount && 1 <= x && x <= eyeDots) {
    //   return true;
    // }

    //top right
    // if (_qrImage.moduleCount - eyeDots + 1 <= x && x <= _qrImage.moduleCount + 1 && y == 1) {
    //   return true;
    // }
    //
    // if (_qrImage.moduleCount - eyeDots + 1 <= x && x <= _qrImage.moduleCount + 1 && y == eyeDots) {
    //   return true;
    // }
    //
    // if (_qrImage.moduleCount - eyeDots + 1  == x && 1 <= y && y <= eyeDots) {
    //   return true;
    // }
    //
    // if (_qrImage.moduleCount == x && 1 <= y && y <= eyeDots) {
    //   return true;
    // }

    if (_qrImage.moduleCount - eyeDots + 1 <= x && x <= _qrImage.moduleCount + 1 && 1 <= y && y <= eyeDots) {
      if ((x == _qrImage.moduleCount - eyeDots + 2 || x == _qrImage.moduleCount - 1) && y != 1 && y != eyeDots)
        return false;
      if ((y == 2 || y == eyeDots - 1) && x != _qrImage.moduleCount - eyeDots + 1 && x != _qrImage.moduleCount) {
        return false;
      }

      return true;
    }


    return false;
  }

  @override
  bool shouldRepaint(PrettyQrCodePainter oldDelegate) => true;
}

