import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/constants.dart';

class MyVerticalDivider extends pw.StatelessWidget {
  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      height: 12.0,
      width: 1.5,
      color: PdfColors.black,
      margin: const pw.EdgeInsets.symmetric(horizontal: PaddingSize.medium),
    );
  }
}
