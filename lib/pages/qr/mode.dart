

enum ColorMode{
  linear,
  gradient
}


extension ColorModeExt on ColorMode{

  String get name {
    switch (this){

      case ColorMode.linear:
        return "Linear Mode";
      case ColorMode.gradient:
        return "Gradient Mode";
    }
  }

}