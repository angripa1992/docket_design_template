import 'dart:typed_data';

import 'package:docket_design_template/utils/printer_configuration.dart';
import 'package:flutter/services.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';

import 'model/z_report_data.dart';

class SunmiZReportPrinter {
  static final _instance = SunmiZReportPrinter._internal();

  factory SunmiZReportPrinter() => _instance;

  SunmiZReportPrinter._internal();

  late SunmiSizeConfig _config;

  Future<bool> _bindingPrinter() async {
    final result = await SunmiPrinter.bindingPrinter();
    return result ?? false;
  }

  Future<void> printZReport(TemplateZReport data, Roll roll) async {
    if (!await _bindingPrinter()) return;
    _config = sunmiSizeConfig(roll);
    await SunmiPrinter.initPrinter();
    await SunmiPrinter.startTransactionPrint(true);
    await _printHeader(data);
    await SunmiPrinter.line();
    await _printSalesSummary(data);
    await _printBrandSummary(data);
    await _printItemsSummary(data);
    await _printItemsModifierSummary(data);
    await _printPaymentMethodSummary(data);
    await _printPaymentChanelSummary(data);
    await _printFooter();
    await SunmiPrinter.cut();
    await SunmiPrinter.exitTransactionPrint(true);
  }

  Future<void> _printHeader(TemplateZReport data) async {
    await SunmiPrinter.printText(
      'Z-Report',
      style: SunmiStyle(
        align: SunmiPrintAlign.LEFT,
        bold: true,
        fontSize: SunmiFontSize.LG,
      ),
    );
    await SunmiPrinter.printText(
      data.reportDate,
      style: SunmiStyle(
        align: SunmiPrintAlign.LEFT,
        bold: true,
        fontSize: SunmiFontSize.MD,
      ),
    );
    await SunmiPrinter.printText(
      'Generated Date: ${data.generatedDate}',
      style: SunmiStyle(
        align: SunmiPrintAlign.LEFT,
        bold: true,
        fontSize: SunmiFontSize.SM,
      ),
    );
  }

  Future<void> _printSalesSummary(TemplateZReport data) async {
    await _printSummaryTitle('Sales Summary');
    for (var summary in data.salesSummary.summaries) {
      await SunmiPrinter.printRow(
        cols: [
          ColumnMaker(
            text: summary.name,
            align: SunmiPrintAlign.LEFT,
            width: _config.left,
          ),
          ColumnMaker(
            text: summary.amount,
            align: SunmiPrintAlign.RIGHT,
            width: _config.right,
          ),
        ],
      );
    }
    await SunmiPrinter.line();
    await _printTotalSales('Total Sales', data.salesSummary.totalSales);
    await _printTotalSales('Discount', data.salesSummary.discount);
    await SunmiPrinter.line();
    await _printTotalSales('Net Sales', data.salesSummary.netSales);
  }

  Future<void> _printBrandSummary(TemplateZReport data) async {
    await _printSummaryTitle('Brand Summary');
    for (var summary in data.brandSummary.summaries) {
      await SunmiPrinter.printRow(
        cols: [
          ColumnMaker(
            text: summary.name,
            align: SunmiPrintAlign.LEFT,
            width: _config.left,
          ),
          ColumnMaker(
            text: summary.amount,
            align: SunmiPrintAlign.RIGHT,
            width: _config.right,
          ),
        ],
      );
    }
    await SunmiPrinter.line();
    await _printTotalSales('Total Sales', data.brandSummary.totalSales);
    await _printTotalSales('Discount', data.brandSummary.discount);
    await SunmiPrinter.line();
    await _printTotalSales('Net Sales', data.brandSummary.netSales);
  }

  Future<void> _printItemsSummary(TemplateZReport data) async {
    await _printSummaryTitle('Item Summary');
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(
      cols: [
        ColumnMaker(
          text: 'Item',
          align: SunmiPrintAlign.LEFT,
          width: _config.tripleColumnLeft,
        ),
        ColumnMaker(
          text: 'Qty',
          align: SunmiPrintAlign.CENTER,
          width: _config.tripleColumnCenter,
        ),
        ColumnMaker(
          text: 'Net Sales',
          align: SunmiPrintAlign.RIGHT,
          width: _config.tripleColumnRight,
        ),
      ],
    );
    await SunmiPrinter.resetBold();
    await SunmiPrinter.line();
    for (var summary in data.itemSummary.summaries) {
      await SunmiPrinter.printRow(
        cols: [
          ColumnMaker(
            text: summary.name,
            align: SunmiPrintAlign.LEFT,
            width: _config.tripleColumnLeft,
          ),
          ColumnMaker(
            text: '(${summary.quantity})',
            align: SunmiPrintAlign.CENTER,
            width: _config.tripleColumnCenter,
          ),
          ColumnMaker(
            text: summary.amount,
            align: SunmiPrintAlign.RIGHT,
            width: _config.tripleColumnRight,
          ),
        ],
      );
    }
    await SunmiPrinter.line();
    await _printTotalSales('Total Sales', data.itemSummary.totalSales);
  }

  Future<void> _printItemsModifierSummary(TemplateZReport data) async {
    await _printSummaryTitle('Modifier Summary');
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(
      cols: [
        ColumnMaker(
          text: 'Modifier',
          align: SunmiPrintAlign.LEFT,
          width: _config.tripleColumnLeft,
        ),
        ColumnMaker(
          text: 'Qty',
          align: SunmiPrintAlign.CENTER,
          width: _config.tripleColumnCenter,
        ),
        ColumnMaker(
          text: 'Net Sales',
          align: SunmiPrintAlign.RIGHT,
          width: _config.tripleColumnRight,
        ),
      ],
    );
    await SunmiPrinter.resetBold();
    await SunmiPrinter.line();
    for (var summary in data.modifierItemSummary.summaries) {
      await SunmiPrinter.printRow(
        cols: [
          ColumnMaker(
            text: summary.name,
            align: SunmiPrintAlign.LEFT,
            width: _config.tripleColumnLeft,
          ),
          ColumnMaker(
            text: '(${summary.quantity})',
            align: SunmiPrintAlign.CENTER,
            width: _config.tripleColumnCenter,
          ),
          ColumnMaker(
            text: summary.amount,
            align: SunmiPrintAlign.RIGHT,
            width: _config.tripleColumnRight,
          ),
        ],
      );
    }
    await SunmiPrinter.line();
    await _printTotalSales('Total Sales', data.modifierItemSummary.totalSales);
  }

  Future<void> _printPaymentMethodSummary(TemplateZReport data) async {
    await _printSummaryTitle('Payment Method Summary');
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(
      cols: [
        ColumnMaker(
          text: 'Payment Method',
          align: SunmiPrintAlign.LEFT,
          width: _config.left,
        ),
        ColumnMaker(
          text: 'Amount',
          align: SunmiPrintAlign.RIGHT,
          width: _config.right,
        ),
      ],
    );
    await SunmiPrinter.resetBold();
    await SunmiPrinter.line();
    for (var summary in data.paymentMethodSummary.summaries) {
      await SunmiPrinter.printRow(
        cols: [
          ColumnMaker(
            text: summary.name,
            align: SunmiPrintAlign.LEFT,
            width: _config.left,
          ),
          ColumnMaker(
            text: summary.amount,
            align: SunmiPrintAlign.RIGHT,
            width: _config.right,
          ),
        ],
      );
    }
    await SunmiPrinter.line();
    await _printTotalSales('Total', data.paymentMethodSummary.totalSales);
    await _printTotalSales('Discount', data.paymentMethodSummary.discount);
    await SunmiPrinter.line();
    await _printTotalSales('Net', data.paymentMethodSummary.netSales);
  }

  Future<void> _printPaymentChanelSummary(TemplateZReport data) async {
    await _printSummaryTitle('Payment Channel Summary');
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(
      cols: [
        ColumnMaker(
          text: 'Payment Channel',
          align: SunmiPrintAlign.LEFT,
          width: _config.left,
        ),
        ColumnMaker(
          text: 'Amount',
          align: SunmiPrintAlign.RIGHT,
          width: _config.right,
        ),
      ],
    );
    await SunmiPrinter.resetBold();
    await SunmiPrinter.line();
    for (var summary in data.paymentChannelSummary.summaries) {
      await SunmiPrinter.printRow(
        cols: [
          ColumnMaker(
            text: summary.name,
            align: SunmiPrintAlign.LEFT,
            width: _config.left,
          ),
          ColumnMaker(
            text: summary.amount,
            align: SunmiPrintAlign.RIGHT,
            width: _config.right,
          ),
        ],
      );
    }
    await SunmiPrinter.line();
    await _printTotalSales('Total', data.paymentChannelSummary.totalSales);
    await _printTotalSales('Discount', data.paymentChannelSummary.discount);
    await SunmiPrinter.line();
    await _printTotalSales('Net', data.paymentChannelSummary.netSales);
  }

  Future<void> _printSummaryTitle(String title) async {
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.printText(
      title,
      style: SunmiStyle(
        align: SunmiPrintAlign.CENTER,
        bold: true,
        fontSize: SunmiFontSize.MD,
      ),
    );
    await SunmiPrinter.lineWrap(1);
  }

  Future<void> _printTotalSales(String title, String amount) async {
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(
      cols: [
        ColumnMaker(
          text: title,
          align: SunmiPrintAlign.LEFT,
          width: _config.left,
        ),
        ColumnMaker(
          text: amount,
          align: SunmiPrintAlign.RIGHT,
          width: _config.right,
        ),
      ],
    );
    await SunmiPrinter.resetBold();
  }

  Future<void> _printFooter() async {
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Powered By');
    Uint8List byte = await _readFileBytes('packages/docket_design_template/assets/images/app_logo.jpg');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printImage(byte);
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Klikit');
    await SunmiPrinter.lineWrap(2);
  }

  Future<Uint8List> _readFileBytes(String path) async {
    ByteData fileData = await rootBundle.load(path);
    Uint8List fileUnit8List = fileData.buffer.asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
    return fileUnit8List;
  }
}
