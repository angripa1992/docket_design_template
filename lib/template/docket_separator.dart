import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DocketSeparator extends pw.StatelessWidget {
  // @override
  // pw.Widget build(pw.Context context) {
  //   return pw.Container(
  //     width: double.infinity,
  //     decoration: const pw.BoxDecoration(
  //       border: pw.Border(
  //         bottom: pw.BorderSide(
  //           color: PdfColors.black,
  //           width: 1.0,
  //           style: pw.BorderStyle.dashed,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  pw.Widget build(pw.Context context) {
    return pw.Divider(color: PdfColors.black,thickness: 0.5,height: 0);
  }
}
