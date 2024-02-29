import 'package:docket_design_template/extensions.dart';
import 'package:docket_design_template/model/order.dart';
import 'package:docket_design_template/string_keys.dart';
import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/template/docket_separator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/brand.dart';
import '../model/font_size.dart';
import '../utils/constants.dart';

class DeliveryInfo extends pw.StatelessWidget {
  final TemplateOrder order;
  final TemplateCartBrand brand;
  final int quantity;
  final PrinterFonts fontSize;

  DeliveryInfo({
    required this.order,
    required this.brand,
    required this.quantity,
    required this.fontSize,
  });

  String _orderType() {
    if (order.type == OrderType.DELIVERY) {
      return 'Delivery';
    } else if (order.type == OrderType.PICKUP) {
      return 'Pickup';
    } else if (order.type == OrderType.DINE_IN) {
      return 'Dine In';
    } else {
      return 'Manual';
    }
  }

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        DocketSeparator(),
        pw.SizedBox(height: PaddingSize.regular),
        pw.Text(
          brand.title,
          style: pw.TextStyle(
            fontSize: fontSize.regularFontSize,
            color: PdfColors.black,
            font: AssetsManager().fontMedium,
            fontFallback: AssetsManager().fontMediumFallback,
          ),
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '$quantity ${StringKeys.item.tr().toLowerCase()}${quantity > 1 ? '(s)' : ''}',
              style: pw.TextStyle(
                fontSize: fontSize.regularFontSize,
                color: PdfColors.black,
                font: AssetsManager().fontRegular,
                fontFallback: AssetsManager().fontRegularFallback,
              ),
            ),
            pw.Text(
              _orderType(),
              style: pw.TextStyle(
                fontSize: fontSize.regularFontSize,
                color: PdfColors.black,
                font: AssetsManager().fontRegular,
                fontFallback: AssetsManager().fontRegularFallback,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: PaddingSize.regular),
        DocketSeparator(),
      ],
    );
  }
}
