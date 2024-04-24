import 'dart:typed_data';
import 'dart:ui';

import 'package:docket_design_template/extensions.dart';
import 'package:docket_design_template/string_keys.dart';
import 'package:docket_design_template/translator.dart';
import 'package:docket_design_template/utils/extension.dart';
import 'package:docket_design_template/utils/printer_configuration.dart';
import 'package:docket_design_template/utils/printer_helper.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;

import 'model/z_report_data.dart';

class CommonZReportTemplate {
  static final _instance = CommonZReportTemplate._internal();

  // PrinterBluetoothManager printerManager = PrinterBluetoothManager();

  factory CommonZReportTemplate() => _instance;

  CommonZReportTemplate._internal();

  Future<List<int>> generateZTicket({required TemplateZReport data, required Roll roll, required Locale locale}) async {
    Translator.setLocale(locale);
    final profile = await CapabilityProfile.load();
    final generator = Generator(roll == Roll.mm58 ? PaperSize.mm58 : PaperSize.mm80, profile, spaceBetweenRows: 1);

    List<int> bytes = [];

    bytes += generator.text(StringKeys.z_report.tr(),
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    bytes += generator.text(data.reportDate, styles: const PosStyles.defaults());
    bytes += PrinterHelper.rowBytes(generator: generator, roll: roll, data: '${StringKeys.generated_date.tr()}: ${data.generatedDate}');
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());

    // _printSalesSummary
    bytes += generator.text(StringKeys.sales_summary.tr(), styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    for (var summary in data.salesSummary.summaries) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: summary.name, str2: summary.amount.replacePhp());
    }
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.total_sales.tr(), str2: data.salesSummary.totalSales.replacePhp());

    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.discount.tr(), str2: data.salesSummary.discount.replacePhp());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.net_sales.tr(), str2: data.salesSummary.netSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());

    //_printBrandSummary
    bytes += generator.text(StringKeys.brand_summary.tr(), styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    for (var summary in data.brandSummary.summaries) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: summary.name, str2: summary.amount.replacePhp());
    }
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.total_sales.tr(), str2: data.brandSummary.totalSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.discount.tr(), str2: data.brandSummary.discount.replacePhp());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.net_sales.tr(), str2: data.brandSummary.netSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());

    //_printItemSummary
    bytes += generator.text(StringKeys.item_summary.tr(), styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.item.tr(), str2: StringKeys.net_sales.tr());
    for (var summary in data.itemSummary.summaries) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${summary.quantity}x ${PrinterHelper.removeSpecialIcon(summary.name)}', str2: summary.amount.replacePhp());
    }
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.total_sales.tr(), str2: data.itemSummary.totalSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());

    //_printModifierSummary
    bytes += generator.text(StringKeys.modifier_summary.tr(), styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.item.tr(), str2: StringKeys.net_sales.tr());

    for (var summary in data.modifierItemSummary.summaries) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${summary.quantity}x ${PrinterHelper.removeSpecialIcon(summary.name)}', str2: summary.amount.replacePhp());
    }
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.total_sales.tr(), str2: data.modifierItemSummary.totalSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());

    //_paymentMethodSummary
    bytes += generator.text(StringKeys.payment_method_summary.tr(), styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.payment_method.tr(), str2: StringKeys.amount.tr());
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());

    for (var summary in data.paymentMethodSummary.summaries) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: summary.name, str2: summary.amount.replacePhp());
    }
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.total.tr(), str2: data.paymentMethodSummary.totalSales.replacePhp());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.discount.tr(), str2: data.paymentMethodSummary.discount.replacePhp());

    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.net_amount.tr(), str2: data.paymentMethodSummary.netSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());

    //_paymentChannelSummary
    bytes += generator.text(StringKeys.payment_channel_summary.tr(), styles: const PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.payment_channel.tr(), str2: StringKeys.amount.tr());
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    for (var summary in data.paymentChannelSummary.summaries) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: summary.name, str2: summary.amount.replacePhp());
    }
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.total.tr(), str2: data.paymentChannelSummary.totalSales.replacePhp());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.discount.tr(), str2: data.paymentChannelSummary.discount.replacePhp());

    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: StringKeys.net_amount.tr(), str2: data.paymentChannelSummary.netSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());

    //footer
    bytes += generator.text(StringKeys.powered_by.tr(), styles: const PosStyles(align: PosAlign.center));

    // Uint8List imageBytesFromAsset = await readFileBytes("packages/docket_design_template/assets/images/app_logo.jpg");
    // final decodedImage = im.decodeImage(imageBytesFromAsset);
    //
    // bytes += generator.imageRaster(decodedImage!, align: PosAlign.center);

    bytes += generator.text('klikit', styles: const PosStyles(bold:true,align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  Future<Uint8List> readFileBytes(String path) async {
    ByteData fileData = await rootBundle.load(path);
    Uint8List fileUnit8List = fileData.buffer.asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
    return fileUnit8List;
  }
}
