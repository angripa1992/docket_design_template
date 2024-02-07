import 'package:docket_design_template/model/font_size.dart';
import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/template/docket_separator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/constants.dart';

class OrderCommentComment extends pw.StatelessWidget {
  final String comment;
  final PrinterFonts fontSize;

  OrderCommentComment({required this.comment, required this.fontSize});

  @override
  pw.Widget build(pw.Context context) {
    return comment.isEmpty ? pw.SizedBox() : pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        DocketSeparator(),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.regular),
          child: pw.Text(
            '** $comment **',
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.regularFontSize,
              font: AssetsManager().fontBold,
              fontFallback: AssetsManager().fontBoldFallback,
            ),
          ),
        ),
      ],
    );
  }
}
