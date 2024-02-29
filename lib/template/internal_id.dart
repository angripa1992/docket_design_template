import 'package:docket_design_template/extensions.dart';
import 'package:docket_design_template/model/order.dart';
import 'package:docket_design_template/string_keys.dart';
import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/utils/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/font_size.dart';

class InternalID extends pw.StatelessWidget {
  final TemplateOrder order;
  final PrinterFonts fontSize;

  InternalID({required this.order, required this.fontSize});

  @override
  pw.Widget build(pw.Context context) {
    final textStyle = pw.TextStyle(
      fontSize: fontSize.regularFontSize,
      color: PdfColors.black,
      font: AssetsManager().fontMedium,
      fontFallback: AssetsManager().fontMediumFallback,
    );

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.regular),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            StringKeys.internal_id.tr(),
            style: textStyle,
          ),
          pw.Text(
            '#${order.id}',
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
