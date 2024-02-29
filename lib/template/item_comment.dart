import 'package:docket_design_template/extensions.dart';
import 'package:docket_design_template/model/font_size.dart';
import 'package:docket_design_template/string_keys.dart';
import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/utils/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ItemComment extends pw.StatelessWidget {
  final String comment;
  final PrinterFonts fontSize;

  ItemComment({required this.comment, required this.fontSize});

  @override
  pw.Widget build(pw.Context context) {
    return comment.isEmpty
        ? pw.SizedBox()
        : pw.Padding(
            padding: const pw.EdgeInsets.only(
              top: PaddingSize.regular,
              bottom: PaddingSize.regular,
            ),
            child: pw.Text(
              '${StringKeys.note.tr()}: $comment',
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: fontSize.smallFontSize,
                font: AssetsManager().fontBold,
                fontFallback: AssetsManager().fontBoldFallback,
              ),
            ),
          );
  }
}
