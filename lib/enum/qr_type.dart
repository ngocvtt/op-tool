enum QrType{
  circle,
  square
}

extension QrTypeEx on QrType{

  String get name{
    switch (this){
      case QrType.circle:
        return "Circle Dot";
      case QrType.square:
        return "Rounded Line";
    }
  }

}