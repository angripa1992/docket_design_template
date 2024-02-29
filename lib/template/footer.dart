import 'package:docket_design_template/extensions.dart';
import 'package:docket_design_template/string_keys.dart';
import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/utils/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/font_size.dart';

class Footer extends pw.StatelessWidget {
  final PrinterFonts fontSize;

  Footer({required this.fontSize});

  @override
  pw.Widget build(pw.Context context) {
    final textStyle = pw.TextStyle(
      color: PdfColors.black,
      fontSize: fontSize.regularFontSize,
      font: AssetsManager().fontRegular,
      fontFallback: AssetsManager().fontRegularFallback,
    );

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        vertical: PaddingSize.medium,
      ),
      child: pw.Column(
        children: [
          pw.Text(
            StringKeys.powered_by.tr(),
            style: textStyle,
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.regular),
            child: pw.Image(
              AssetsManager().footerImage,
              width: 30,
              height: 30,
            ),
          ),
          pw.Text(
            'klikit',
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
