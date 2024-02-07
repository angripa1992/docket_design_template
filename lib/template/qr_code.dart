import 'package:docket_design_template/model/brand.dart';
import 'package:docket_design_template/model/font_size.dart';
import 'package:docket_design_template/model/order.dart';
import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/utils/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class QRCode extends pw.StatelessWidget {
  final QrInfo qrInfo;
  final PrinterFonts fontSize;

  QRCode({required this.qrInfo, required this.fontSize});

  @override
  pw.Widget build(pw.Context context) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.medium),
      child: pw.Column(
        children: [
          pw.Text(
            qrInfo.qrLabel,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.regularFontSize,
              font: AssetsManager().fontRegular,
              fontFallback: AssetsManager().fontRegularFallback,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.large),
            child: pw.BarcodeWidget(
              color: PdfColor.fromHex("#000000"),
              barcode: pw.Barcode.qrCode(),
              data: qrInfo.qrContent,
              height: 80,
              width: 80,
            ),
          ),
        ],
      ),
    );
  }
}
