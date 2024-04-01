import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/template/zreport_design.dart';
import 'package:docket_design_template/translator.dart';
import 'package:docket_design_template/utils/constants.dart';
import 'package:docket_design_template/utils/file_manager.dart';
import 'package:docket_design_template/utils/printer_configuration.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'package:pdf/pdf.dart' as pdef;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';

import 'model/z_report_data.dart';

class ZReportDesignTemplate {
  static final _instance = ZReportDesignTemplate._internal();

  static const double inch = 72.0;
  static const double mm = inch / 25.4;

  factory ZReportDesignTemplate() => _instance;

  ZReportDesignTemplate._internal();

  Future<List<int>?> generateTicket(TemplateZReport data, PrinterConfiguration printerConfiguration, Locale locale) async {
    final file = await FileManager().createFile();
    final generatedPdf = await _generatePdf(data: data, printerConfiguration: printerConfiguration, locale: locale);
    await FileManager().writeToFile(file: file, bytesData: generatedPdf);
    final pdfImage = await _generatePdfImage(file);
    if (pdfImage == null) return null;
    final printableImageBytes = await _generateBytesFromPdfImage(pdfImage, printerConfiguration.roll);
    await FileManager().deleteFile(file);
    return printableImageBytes;
  }

  Future<Uint8List?> generatePdfImage(TemplateZReport data, PrinterConfiguration printerConfiguration, Locale locale) async {
    final file = await FileManager().createFile();
    final generatedPdf = await _generatePdf(data: data, printerConfiguration: printerConfiguration, locale: locale);
    await FileManager().writeToFile(file: file, bytesData: generatedPdf);
    final pdfImage = await _generatePdfImage(file);
    await FileManager().deleteFile(file);
    return pdfImage?.bytes;
  }

  Future<PdfPageImage?> _generatePdfImage(File file) async {
    final document = await PdfDocument.openFile(file.path);
    var page = await document.getPage(1);
    final pageImage = await page.render(
      width: page.width * 2,
      height: page.height * 2,
      format: PdfPageImageFormat.png,
      backgroundColor: '#ffffff',
    );
    return pageImage;
  }

  Future<List<int>?> _generateBytesFromPdfImage(
    PdfPageImage pdfPageImage,
    Roll roll,
  ) async {
    try {
      final imageBytes = pdfPageImage.bytes;
      final decodedImage = im.decodeImage(imageBytes);
      List<int> printableImageBytes = [];
      final profile = await CapabilityProfile.load();
      final generator = Generator((roll == Roll.mm80) ? PaperSize.mm80 : PaperSize.mm58, profile);
      printableImageBytes += generator.image(decodedImage!);
      printableImageBytes += generator.feed(2);
      printableImageBytes += generator.cut();
      return printableImageBytes;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List> _generatePdf({
    required TemplateZReport data,
    required PrinterConfiguration printerConfiguration,
    required Locale locale,
  }) async {
    final paperRoll = (printerConfiguration.roll == Roll.mm58) ? RollPaperWidth.mm58 : RollPaperWidth.mm80;
    final pdf = pw.Document();
    await AssetsManager().initAssets();
    Translator.setLocale(locale);
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(0),
        pageFormat: pdef.PdfPageFormat(
          paperRoll * mm,
          double.infinity,
          marginAll: 0,
        ),
        build: (pw.Context context) => ZReportDesign(data: data, fontSize: printerConfiguration.fontSize),
      ),
    );
    return pdf.save();
  }
}
