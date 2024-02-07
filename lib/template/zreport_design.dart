import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/utils/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/font_size.dart';
import '../model/z_report_data.dart';
import 'footer.dart';

class ZReportDesign extends pw.StatelessWidget {
  final TemplateZReport data;
  final PrinterFonts fontSize;

  ZReportDesign({
    required this.data,
    required this.fontSize,
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.medium),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _header(),
          _divider(),
          _salesSummary(),
          _brandSummary(),
          _itemSummary(),
          _itemModifierSummary(),
          _paymentMethodSummary(),
          _paymentChannelSummary(),
          pw.SizedBox(height: PaddingSize.medium),
          Footer(fontSize: fontSize),
        ],
      ),
    );
  }

  pw.Widget _header() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          'Z-Report',
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: fontSize.extraLargeFontSize,
            font: AssetsManager().fontBold,
            fontFallback: AssetsManager().fontBoldFallback,
          ),
        ),
        pw.Text(
          data.reportDate,
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: fontSize.largeFontSize,
            font: AssetsManager().fontBold,
            fontFallback: AssetsManager().fontBoldFallback,
          ),
        ),
        pw.Text(
          'Generated Date: ${data.generatedDate}',
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: fontSize.mediumFontSize,
            font: AssetsManager().fontSemiBold,
            fontFallback: AssetsManager().fontSemiBoldFallback,
          ),
        ),
      ],
    );
  }

  pw.Widget _salesSummary() {
    return pw.Column(children: [
      _title('Sales Summary'),
      pw.Column(
        children: data.salesSummary.summaries.map((summary) {
          return _doubleColumnTable(
            left: summary.name,
            right: summary.amount,
            textStyle: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontMedium,
              fontFallback: AssetsManager().fontMediumFallback,
            ),
          );
        }).toList(),
      ),
      _divider(),
      _total('Total Sales', data.salesSummary.totalSales),
      _total('Discount', data.salesSummary.discount),
      _divider(),
      _total('Net Sales', data.salesSummary.netSales),
    ]);
  }

  pw.Widget _brandSummary() {
    return pw.Column(children: [
      _title('Brand Summary'),
      pw.Column(
        children: data.brandSummary.summaries.map((summary) {
          return _doubleColumnTable(
            left: summary.name,
            right: summary.amount,
            textStyle: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontMedium,
              fontFallback: AssetsManager().fontMediumFallback,
            ),
          );
        }).toList(),
      ),
      _divider(),
      _total('Total Sales', data.brandSummary.totalSales),
      _total('Discount', data.brandSummary.discount),
      _divider(),
      _total('Net Sales', data.brandSummary.netSales),
    ]);
  }

  pw.Widget _itemSummary() {
    return pw.Column(children: [
      _title('Item Summary'),
      _threeColumnTable(
        left: 'Item',
        center: 'Quantity',
        right: 'Net Sales',
        textStyle: pw.TextStyle(
          color: PdfColors.black,
          fontSize: fontSize.mediumFontSize,
          font: AssetsManager().fontSemiBold,
          fontFallback: AssetsManager().fontSemiBoldFallback,
        ),
      ),
      _divider(),
      pw.Column(
        children: data.itemSummary.summaries.map((summary) {
          return _threeColumnTable(
            left: summary.name,
            center: '${summary.quantity}',
            right: summary.amount,
            textStyle: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontMedium,
              fontFallback: AssetsManager().fontMediumFallback,
            ),
          );
        }).toList(),
      ),
      _divider(),
      _total('Total Sales', data.itemSummary.totalSales),
    ]);
  }

  pw.Widget _itemModifierSummary() {
    return pw.Column(children: [
      _title('Modifier Summary'),
      _threeColumnTable(
        left: 'Modifier',
        center: 'Quantity',
        right: 'Net Sales',
        textStyle: pw.TextStyle(
          color: PdfColors.black,
          fontSize: fontSize.mediumFontSize,
          font: AssetsManager().fontSemiBold,
          fontFallback: AssetsManager().fontSemiBoldFallback,
        ),
      ),
      _divider(),
      pw.Column(
        children: data.modifierItemSummary.summaries.map((summary) {
          return _threeColumnTable(
            left: summary.name,
            center: '${summary.quantity}',
            right: summary.amount,
            textStyle: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontMedium,
              fontFallback: AssetsManager().fontMediumFallback,
            ),
          );
        }).toList(),
      ),
      _divider(),
      _total('Total Sales', data.modifierItemSummary.totalSales),
    ]);
  }

  pw.Widget _paymentMethodSummary() {
    return pw.Column(children: [
      _title('Payment Method Summary'),
      _doubleColumnTable(
        left: 'Payment Method',
        right: 'Amount',
        textStyle: pw.TextStyle(
          color: PdfColors.black,
          fontSize: fontSize.mediumFontSize,
          font: AssetsManager().fontSemiBold,
          fontFallback: AssetsManager().fontSemiBoldFallback,
        ),
      ),
      _divider(),
      pw.Column(
        children: data.paymentMethodSummary.summaries.map((summary) {
          return _doubleColumnTable(
            left: summary.name,
            right: summary.amount,
            textStyle: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontMedium,
              fontFallback: AssetsManager().fontMediumFallback,
            ),
          );
        }).toList(),
      ),
      _divider(),
      _total('Total', data.paymentMethodSummary.totalSales),
      _total('Discount', data.paymentMethodSummary.discount),
      _divider(),
      _total('Net', data.paymentMethodSummary.netSales),
    ]);
  }

  pw.Widget _paymentChannelSummary() {
    return pw.Column(children: [
      _title('Payment Channel Summary'),
      _doubleColumnTable(
        left: 'Payment Channel',
        right: 'Amount',
        textStyle: pw.TextStyle(
          color: PdfColors.black,
          fontSize: fontSize.mediumFontSize,
          font: AssetsManager().fontSemiBold,
          fontFallback: AssetsManager().fontSemiBoldFallback,
        ),
      ),
      _divider(),
      pw.Column(
        children: data.paymentChannelSummary.summaries.map((summary) {
          return _doubleColumnTable(
            left: summary.name,
            right: summary.amount,
            textStyle: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontMedium,
              fontFallback: AssetsManager().fontMediumFallback,
            ),
          );
        }).toList(),
      ),
      _divider(),
      _total('Total', data.paymentChannelSummary.totalSales),
      _total('Discount', data.paymentChannelSummary.discount),
      _divider(),
      _total('Net', data.paymentChannelSummary.netSales),
    ]);
  }

  pw.Widget _title(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.large),
      child: pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text(
          title,
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: fontSize.mediumFontSize,
            font: AssetsManager().fontBold,
            fontFallback: AssetsManager().fontBoldFallback,
          ),
        ),
      ),
    );
  }

  pw.Widget _doubleColumnTable({
    required String left,
    required String right,
    required pw.TextStyle textStyle,
  }) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              left,
              style: textStyle,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              right,
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _threeColumnTable({
    required String left,
    required String right,
    required String center,
    required pw.TextStyle textStyle,
  }) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              left,
              style: textStyle,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              center,
              style: textStyle,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              right,
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _total(String title, String amount) {
    return _doubleColumnTable(
      left: title,
      right: amount,
      textStyle: pw.TextStyle(
        color: PdfColors.black,
        fontSize: fontSize.mediumFontSize,
        font: AssetsManager().fontBold,
        fontFallback: AssetsManager().fontBoldFallback,
      ),
    );
  }

  pw.Widget _divider() {
    return pw.Divider();
  }
}
