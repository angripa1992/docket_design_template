import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AssetsManager {
  static final _instance = AssetsManager._internal();

  factory AssetsManager() => _instance;

  AssetsManager._internal();

  List<pw.Font> fontRegularFallback = [];
  List<pw.Font> fontBoldFallback = [];
  List<pw.Font> fontSemiBoldFallback = [];
  List<pw.Font> fontMediumFallback = [];

  late pw.Font fontRegular;
  late pw.Font fontRegularThai;
  late pw.Font fontRegularChinese;
  late pw.Font fontBold;
  late pw.Font fontBoldThai;
  late pw.Font fontBoldChinese;
  late pw.Font fontMedium;
  late pw.Font fontMediumBengali;
  late pw.Font fontMediumThai;
  late pw.Font fontMediumChinese;
  late pw.Font fontSemiBold;
  late pw.Font fontSemiBoldThai;
  late pw.Font fontSemiBoldChinese;
  late pw.Font fontBoldRoboto;
  late pw.Font fontRegularRoboto;
  late pw.Font fontMediumRoboto;
  late pw.MemoryImage footerImage;

  Future initAssets() async {
    fontRegular = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/NotoSans-Regular.ttf');
    fontMedium = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/NotoSans-Medium.ttf');
    fontSemiBold = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/NotoSans-SemiBold.ttf');
    fontBold = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/NotoSans-Bold.ttf');

    fontRegularThai = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/NotoSansThai-Regular.ttf');
    fontMediumThai = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/NotoSansThai-Medium.ttf');
    fontSemiBoldThai = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/NotoSansThai-SemiBold.ttf');
    fontBoldThai = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/NotoSansThai-Bold.ttf');

    fontRegularChinese = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/AlibabaPuHuiTi-2-65-Medium.ttf');
    fontBoldChinese = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/AlibabaPuHuiTi-2-65-Medium.ttf');
    fontMediumChinese = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/AlibabaPuHuiTi-2-65-Medium.ttf');
    fontSemiBoldChinese = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/AlibabaPuHuiTi-2-65-Medium.ttf');

    fontRegularRoboto = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/Roboto-Regular.ttf');
    fontMediumRoboto = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/Roboto-Medium.ttf');
    fontBoldRoboto = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/Roboto-Bold.ttf');

    fontMediumBengali = await fontFromAssetBundle('packages/docket_design_template/assets/fonts/NotoSansBengali-Medium.ttf');

    fontRegularFallback = [fontRegular, fontRegularThai, fontRegularChinese, fontRegularRoboto, fontMediumBengali];
    fontBoldFallback = [fontBold, fontBoldThai, fontBoldChinese, fontBoldRoboto, fontMediumBengali];
    fontSemiBoldFallback = [fontSemiBold, fontSemiBoldThai, fontSemiBoldChinese, fontMediumBengali];
    fontMediumFallback = [fontMedium, fontMediumThai, fontMediumChinese, fontMediumRoboto, fontMediumBengali];

    final imageByteData = await rootBundle.load('packages/docket_design_template/assets/images/app_logo.png');
    footerImage = pw.MemoryImage((imageByteData).buffer.asUint8List());
  }

  Future<ByteData> loadFont(String path) async {
    File file = File(path);
    Uint8List bytes = await file.readAsBytes();
    return ByteData.view(bytes.buffer);
  }
}
