import 'package:qr_generator/enum/qr_type.dart';
import 'package:qr_generator/model/logo_config.dart';

class QrConfig{
  LogoConfig logoConfig;
  QrType qrType;

  QrConfig(this.logoConfig, {this.qrType = QrType.circle});
}