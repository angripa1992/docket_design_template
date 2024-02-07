import 'package:docket_design_template/model/font_size.dart';
import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/utils/constants.dart';
import 'package:pdf/widgets.dart' as pw;

class CartItemsHeader extends pw.StatelessWidget {
  final PrinterFonts fontSize;
  CartItemsHeader({required this.fontSize});
  @override
  pw.Widget build(pw.Context context) {
    final textStyle = pw.TextStyle(
      fontSize: fontSize.regularFontSize,
      font: AssetsManager().fontMedium,
      fontFallback: AssetsManager().fontMediumFallback,
    );
    return pw.Row(
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            'Items',
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Price',
              style: textStyle,
            ),
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'QTY',
              style: textStyle,
            ),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total',
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }
}
