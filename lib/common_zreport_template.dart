import 'dart:typed_data';

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
    bytes += generator.text('Generated Date: ${data.generatedDate}',styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    // _printSalesSummary
    bytes += generator.text('Sales Summary',styles: const PosStyles(bold: true,align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    for (var summary in data.salesSummary.summaries) {

      var names = PrinterHelper.splitTextToFitRow(text: summary.name, roll: roll,fillRow: true);
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,names[0], summary.amount),styles: const PosStyles(align: PosAlign.left));

      for (int i=1;i<names.length;i++) {
        bytes += generator.text(names[i],styles: const PosStyles.defaults());
      }

    }
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Total Sales', data.salesSummary.totalSales),styles: const PosStyles(align: PosAlign.left));

    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Discount', data.salesSummary.discount),styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Net Sales', data.salesSummary.netSales),styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    //_printBrandSummary
    bytes += generator.text('Brand Summary',styles: const PosStyles(bold: true,align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    for (var summary in data.brandSummary.summaries) {
      var names = PrinterHelper.splitTextToFitRow(text: summary.name, roll: roll,fillRow: true);
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,summary.name, summary.amount),styles: const PosStyles(align: PosAlign.left));

      for (int i=1;i<names.length;i++) {
        bytes += generator.text(names[i],styles: const PosStyles.defaults());
      }
    }
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Total Sales', data.brandSummary.totalSales),styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());


    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Discount', data.brandSummary.discount),styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Net Sales', data.brandSummary.netSales),styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    //_printItemSummary
    bytes += generator.text('Item Summary',styles: const PosStyles(bold: true,align: PosAlign.center));

    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Item', 'Net Sales'),styles: const PosStyles(align: PosAlign.left));

    for (var summary in data.itemSummary.summaries) {
      var names = PrinterHelper.splitTextToFitRow(text: '${summary.quantity}x ${summary.name}', roll: roll,fillRow: true);
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,names[0], summary.amount),styles: const PosStyles(align: PosAlign.left));
      for (int i=1;i<names.length;i++) {
        bytes += generator.text(names[i],styles: const PosStyles.defaults());
      }
    }
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Total Sales', data.itemSummary.totalSales),styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    //_printModifierSummary
    bytes += generator.text('Modifier Summary',styles: const PosStyles(bold: true,align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Item', 'Net Sales'),styles: const PosStyles(align: PosAlign.left));

    for (var summary in data.modifierItemSummary.summaries) {
      var names = PrinterHelper.splitTextToFitRow(text: '${summary.quantity}x ${summary.name}', roll: roll,fillRow: true);
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,names[0], summary.amount),styles: const PosStyles(align: PosAlign.left));
      for (int i=1;i<names.length;i++) {
        bytes += generator.text(names[i],styles: const PosStyles.defaults());
      }
    }
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Total Sales', data.modifierItemSummary.totalSales),styles: const PosStyles(align: PosAlign.left));

    //_paymentMethodSummary
    bytes += generator.text('Payment Method Summary',styles: const PosStyles(bold: true,align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Payment Method', 'Amount'),styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    for (var summary in data.paymentMethodSummary.summaries) {
      var names =PrinterHelper.splitTextToFitRow(text: summary.name, roll: roll,fillRow: true);
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,names[0], summary.amount),styles: const PosStyles(align: PosAlign.left));
      for (int i=1;i<names.length;i++) {
        bytes += generator.text(names[i],styles: const PosStyles.defaults());
      }
    }
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Total', data.paymentMethodSummary.totalSales),styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Discount', data.paymentMethodSummary.discount),styles: const PosStyles(align: PosAlign.left));

    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Net', data.paymentMethodSummary.netSales),styles: const PosStyles(align: PosAlign.left));

    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());

    //_paymentChannelSummary
    bytes += generator.text('Payment Channel Summary',styles: const PosStyles(bold: true,align: PosAlign.center));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Payment Channel', 'Amount'),styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    for (var summary in data.paymentChannelSummary.summaries) {
      var names = PrinterHelper.splitTextToFitRow(text: summary.name, roll: roll,fillRow: true);
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,names[0], summary.amount),styles: const PosStyles(align: PosAlign.left));
      for (int i=1;i<names.length;i++) {
        bytes += generator.text(names[i],styles: const PosStyles.defaults());
      }
    }
    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Total', data.paymentChannelSummary.totalSales),styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Discount', data.paymentChannelSummary.discount),styles: const PosStyles(align: PosAlign.left));

    bytes += generator.text(PrinterHelper.getLine(roll),styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Net', data.paymentChannelSummary.netSales),styles: const PosStyles(align: PosAlign.left));

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
