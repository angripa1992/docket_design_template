import 'package:docket_design_template/extensions.dart';
import 'package:docket_design_template/model/font_size.dart';
import 'package:docket_design_template/string_keys.dart';
import 'package:docket_design_template/template/assets_manager.dart';
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
            StringKeys.items.tr(),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              StringKeys.price.tr(),
              style: textStyle,
            ),
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              StringKeys.qty.tr(),
              style: textStyle,
            ),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              StringKeys.total.tr(),
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }
}
