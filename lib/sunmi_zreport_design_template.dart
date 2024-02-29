import 'dart:typed_data';
import 'dart:ui';

import 'package:docket_design_template/extensions.dart';
import 'package:docket_design_template/string_keys.dart';
import 'package:docket_design_template/translator.dart';
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

  Future<void> printZReport(TemplateZReport data, Roll roll, Locale locale) async {
    if (!await _bindingPrinter()) return;
    Translator.setLocale(locale);
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
      StringKeys.z_report.tr(),
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
      '${StringKeys.generated_date.tr()}: ${data.generatedDate}',
      style: SunmiStyle(
        align: SunmiPrintAlign.LEFT,
        bold: true,
        fontSize: SunmiFontSize.SM,
      ),
    );
  }

  Future<void> _printSalesSummary(TemplateZReport data) async {
    await _printSummaryTitle(StringKeys.sales_summary.tr());
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
    await _printTotalSales(StringKeys.total_sales.tr(), data.salesSummary.totalSales);
    await _printTotalSales(StringKeys.discount.tr(), data.salesSummary.discount);
    await SunmiPrinter.line();
    await _printTotalSales(StringKeys.net_sales.tr(), data.salesSummary.netSales);
  }

  Future<void> _printBrandSummary(TemplateZReport data) async {
    await _printSummaryTitle(StringKeys.brand_summary.tr());
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
    await _printTotalSales(StringKeys.total_sales.tr(), data.brandSummary.totalSales);
    await _printTotalSales(StringKeys.discount.tr(), data.brandSummary.discount);
    await SunmiPrinter.line();
    await _printTotalSales(StringKeys.net_sales.tr(), data.brandSummary.netSales);
  }

  Future<void> _printItemsSummary(TemplateZReport data) async {
    await _printSummaryTitle(StringKeys.item_summary.tr());
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(
      cols: [
        ColumnMaker(
          text: StringKeys.item.tr(),
          align: SunmiPrintAlign.LEFT,
          width: _config.tripleColumnLeft,
        ),
        ColumnMaker(
          text: StringKeys.qty.tr(),
          align: SunmiPrintAlign.CENTER,
          width: _config.tripleColumnCenter,
        ),
        ColumnMaker(
          text: StringKeys.net_sales.tr(),
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
    await _printTotalSales(StringKeys.total_sales.tr(), data.itemSummary.totalSales);
  }

  Future<void> _printItemsModifierSummary(TemplateZReport data) async {
    await _printSummaryTitle(StringKeys.modifier_summary.tr());
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(
      cols: [
        ColumnMaker(
          text: StringKeys.modifier.tr(),
          align: SunmiPrintAlign.LEFT,
          width: _config.tripleColumnLeft,
        ),
        ColumnMaker(
          text: StringKeys.qty.tr(),
          align: SunmiPrintAlign.CENTER,
          width: _config.tripleColumnCenter,
        ),
        ColumnMaker(
          text: StringKeys.net_sales.tr(),
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
    await _printTotalSales(StringKeys.total_sales.tr(), data.modifierItemSummary.totalSales);
  }

  Future<void> _printPaymentMethodSummary(TemplateZReport data) async {
    await _printSummaryTitle(StringKeys.payment_method_summary.tr());
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(
      cols: [
        ColumnMaker(
          text: StringKeys.payment_method.tr(),
          align: SunmiPrintAlign.LEFT,
          width: _config.left,
        ),
        ColumnMaker(
          text: StringKeys.amount.tr(),
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
    await _printTotalSales(StringKeys.total.tr(), data.paymentMethodSummary.totalSales);
    await _printTotalSales(StringKeys.discount.tr(), data.paymentMethodSummary.discount);
    await SunmiPrinter.line();
    await _printTotalSales(StringKeys.net_amount.tr(), data.paymentMethodSummary.netSales);
  }

  Future<void> _printPaymentChanelSummary(TemplateZReport data) async {
    await _printSummaryTitle(StringKeys.payment_channel_summary.tr());
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(
      cols: [
        ColumnMaker(
          text: StringKeys.payment_channel.tr(),
          align: SunmiPrintAlign.LEFT,
          width: _config.left,
        ),
        ColumnMaker(
          text: StringKeys.amount.tr(),
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
    await _printTotalSales(StringKeys.total.tr(), data.paymentChannelSummary.totalSales);
    await _printTotalSales(StringKeys.discount.tr(), data.paymentChannelSummary.discount);
    await SunmiPrinter.line();
    await _printTotalSales(StringKeys.net_amount.tr(), data.paymentChannelSummary.netSales);
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
    await SunmiPrinter.printText(StringKeys.powered_by.tr());
    Uint8List byte = await _readFileBytes('packages/docket_design_template/assets/images/app_logo.jpg');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printImage(byte);
    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('klikit');
    await SunmiPrinter.lineWrap(2);
  }

  Future<Uint8List> _readFileBytes(String path) async {
    ByteData fileData = await rootBundle.load(path);
    Uint8List fileUnit8List = fileData.buffer.asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
    return fileUnit8List;
  }
}
