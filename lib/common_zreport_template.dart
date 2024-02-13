import 'dart:typed_data';

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


  
  Future<List<int>> generateZTicket({required TemplateZReport data, required Roll roll}) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(roll == Roll.mm58?PaperSize.mm58:PaperSize.mm80, profile,spaceBetweenRows :1);

    List<int> bytes = [];

    bytes += generator.text('Z-Report',styles:const PosStyles(
      height: PosTextSize.size2,
      width: PosTextSize.size2,

    ));
    bytes += generator.text(data.reportDate,styles: const PosStyles.defaults());
    bytes += PrinterHelper.rowBytes(generator: generator, roll: roll, data: 'Generated Date: ${data.generatedDate}');
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    // _printSalesSummary
    bytes += generator.text('Sales Summary',styles: const PosStyles(bold: true,align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    for (var summary in data.salesSummary.summaries) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: summary.name,str2: summary.amount.replacePhp());
    }
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Total Sales',str2: data.salesSummary.totalSales.replacePhp());

    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Discount',str2: data.salesSummary.discount.replacePhp());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Net Sales',str2: data.salesSummary.netSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    //_printBrandSummary
    bytes += generator.text('Brand Summary',styles: const PosStyles(bold: true,align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    for (var summary in data.brandSummary.summaries) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: summary.name,str2: summary.amount.replacePhp());
    }
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Total Sales',str2: data.brandSummary.totalSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Discount',str2: data.brandSummary.discount.replacePhp());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Net Sales',str2: data.brandSummary.netSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    //_printItemSummary
    bytes += generator.text('Item Summary',styles: const PosStyles(bold: true,align: PosAlign.center));
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Item',str2: 'Net Sales');
    for (var summary in data.itemSummary.summaries) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${summary.quantity}x ${summary.name}',str2: summary.amount.replacePhp());
    }
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Total Sales',str2: data.itemSummary.totalSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    //_printModifierSummary
    bytes += generator.text('Modifier Summary',styles: const PosStyles(bold: true,align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Item',str2: 'Net Sales');

    for (var summary in data.modifierItemSummary.summaries) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${summary.quantity}x ${summary.name}',str2: summary.amount.replacePhp());
    }
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Total Sales',str2: data.modifierItemSummary.totalSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    //_paymentMethodSummary
    bytes += generator.text('Payment Method Summary',styles: const PosStyles(bold: true,align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Payment Method',str2: 'Amount');
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    for (var summary in data.paymentMethodSummary.summaries) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: summary.name,str2: summary.amount.replacePhp());
    }
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Total',str2: data.paymentMethodSummary.totalSales.replacePhp());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Discount',str2: data.paymentMethodSummary.discount.replacePhp());

    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Net',str2: data.paymentMethodSummary.netSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    //_paymentChannelSummary
    bytes += generator.text('Payment Channel Summary',styles: const PosStyles(bold: true,align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Payment Channel',str2: 'Amount');
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    for (var summary in data.paymentChannelSummary.summaries) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: summary.name,str2: summary.amount.replacePhp());
    }
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Total',str2: data.paymentChannelSummary.totalSales.replacePhp());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Discount',str2: data.paymentChannelSummary.discount.replacePhp());

    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Net',str2: data.paymentChannelSummary.netSales.replacePhp());
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    //footer
    bytes += generator.text('Powered by',styles: const PosStyles(bold: true,align: PosAlign.center));
    // ByteData bytesData = await rootBundle.load("packages/docket_design_template/assets/images/app_logo.jpg");
    // Uint8List imageBytesFromAsset = bytesData.buffer
    //     .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes);
    // final decodedImage = im.decodeImage(imageBytesFromAsset);
    // bytes += generator.image(decodedImage!);
    bytes += generator.text('klikit',styles: const PosStyles(bold: true,align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }
}
