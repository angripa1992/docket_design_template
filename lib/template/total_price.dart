import 'package:docket_design_template/model/font_size.dart';
import 'package:docket_design_template/model/order.dart';
import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/utils/price_calculator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class TotalPrice extends pw.StatelessWidget {
  final TemplateOrder order;
  final PrinterFonts fontSize;

  TotalPrice({required this.order, required this.fontSize});

  @override
  pw.Widget build(pw.Context context) {
    final textStyle = pw.TextStyle(
      color: PdfColors.black,
      fontSize: fontSize.largeFontSize,
      font: AssetsManager().fontBold,
      fontFallback: AssetsManager().fontBoldFallback,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Total:',
          style: textStyle,
        ),
        pw.Text(
          PriceCalculator.convertPrice(order, order.providerGrandTotal),
          style: textStyle,
        ),
      ],
    );
  }
}
