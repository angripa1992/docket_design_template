import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:docket_design_template/model/cart.dart';
import 'package:docket_design_template/model/order.dart';
import 'package:docket_design_template/template/design_template.dart';
import 'package:docket_design_template/translator.dart';
import 'package:docket_design_template/utils/file_manager.dart';
import 'package:docket_design_template/utils/printer_configuration.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'package:pdfx/pdfx.dart';

class DocketDesignTemplate {
  static final _instance = DocketDesignTemplate._internal();

  factory DocketDesignTemplate() => _instance;

  DocketDesignTemplate._internal();

  Future<List<int>?> generateTicket(
    TemplateOrder order,
    PrinterConfiguration printerConfiguration,
    Locale locale,
  ) async {
    Translator.setLocale(locale);
    final cartMap = await _mapOrder(order);
    final file = await FileManager().createFile();
    final generatedPdf = await DesignTemplate().generatePdf(
      order: order,
      printerConfiguration: printerConfiguration,
      cartMap: cartMap,
    );
    await FileManager().writeToFile(file: file, bytesData: generatedPdf);
    final pdfImage = await _generatePdfImage(file);
    if (pdfImage == null) return null;
    final printableImageBytes = await _generateBytesFromPdfImage(pdfImage, printerConfiguration.roll);
    await FileManager().deleteFile(file);
    return printableImageBytes;
  }

  Future<Uint8List?> generatePdfImage(
    TemplateOrder order,
    PrinterConfiguration printerConfiguration,
    Locale locale,
  ) async {
    Translator.setLocale(locale);
    final cartMap = await _mapOrder(order);
    final file = await FileManager().createFile();
    final generatedPdf = await DesignTemplate().generatePdf(
      order: order,
      printerConfiguration: printerConfiguration,
      cartMap: cartMap,
    );
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

  Future<Map<int, List<TemplateCart>>> _mapOrder(TemplateOrder order) async {
    Map<int, List<TemplateCart>> filteredOrders = {};
    for (var cart in order.cartV2) {
      if (filteredOrders.containsKey(cart.cartBrand.id)) {
        List<TemplateCart> carts = filteredOrders[cart.cartBrand.id]!;
        carts.add(cart);
        filteredOrders[cart.cartBrand.id] = carts;
      } else {
        List<TemplateCart> carts = [];
        carts.add(cart);
        filteredOrders[cart.cartBrand.id] = carts;
      }
    }
    return filteredOrders;
  }
}
