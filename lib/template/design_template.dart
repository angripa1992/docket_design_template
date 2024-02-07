library docket_design_template;

import 'package:docket_design_template/model/font_size.dart';
import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/template/cart_items.dart';
import 'package:docket_design_template/template/docket_separator.dart';
import 'package:docket_design_template/template/footer.dart';
import 'package:docket_design_template/template/header.dart';
import 'package:docket_design_template/template/internal_id.dart';
import 'package:docket_design_template/template/klikit_comment.dart';
import 'package:docket_design_template/template/order_comment.dart';
import 'package:docket_design_template/template/price_details.dart';
import 'package:docket_design_template/template/qr_code.dart';
import 'package:docket_design_template/utils/printer_configuration.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/cart.dart';
import '../model/order.dart';
import '../utils/constants.dart';
import 'deliver_info.dart';

class DesignTemplate {
  static final _instance = DesignTemplate._internal();

  factory DesignTemplate() => _instance;

  DesignTemplate._internal();

  static const double inch = 72.0;
  static const double mm = inch / 25.4;

  Future<Uint8List> generatePdf({
    required TemplateOrder order,
    required PrinterConfiguration printerConfiguration,
    required Map<int, List<TemplateCart>> cartMap,
  }) async {
    final paperRoll = (printerConfiguration.roll == Roll.mm58) ? RollPaperWidth.mm58 : RollPaperWidth.mm80;
    final pdf = pw.Document();
    await AssetsManager().initAssets();
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(0),
        pageFormat: PdfPageFormat(paperRoll * mm, double.infinity, marginAll: 0),
        build: (pw.Context context) => printerConfiguration.docket == Docket.customer
            ? _generateCustomerCopyPdf(
                order,
                printerConfiguration.fontSize,
                cartMap: cartMap,
                printingType: printerConfiguration.printingType,
              )
            : _generateKitchenCopyPdf(
                order,
                printerConfiguration.fontSize,
                cartMap: cartMap,
                printingType: printerConfiguration.printingType,
              ),
      ),
    );
    return pdf.save();
  }

  pw.Widget _generateCustomerCopyPdf(
    TemplateOrder order,
    PrinterFonts fontSize, {
    required Map<int, List<TemplateCart>> cartMap,
    required PrintingType printingType,
  }) {
    return pw.Column(
      children: [
        Header(order, true, fontSize, printingType),
        OrderCommentComment(comment: order.orderComment, fontSize: fontSize),
        CartItems(order, cartMap, isKitchenCopy: false, fontSize: fontSize),
        DocketSeparator(),
        PriceDetails(order: order, fontSize: fontSize),
        DocketSeparator(),
        InternalID(order: order, fontSize: fontSize),
        DocketSeparator(),
        if (order.isThreePlOrder) DeliverInfo(order: order, fontSize: fontSize),
        if (order.isThreePlOrder) DocketSeparator(),
        KlikitComment(comment: order.klikitComment, fontSize: fontSize),
        if (order.qrInfo != null) QRCode(qrInfo: order.qrInfo!, fontSize: fontSize),
        Footer(fontSize: fontSize),
      ],
    );
  }

  pw.Widget _generateKitchenCopyPdf(
    TemplateOrder order,
    PrinterFonts fontSize, {
    required Map<int, List<TemplateCart>> cartMap,
    required PrintingType printingType,
  }) {
    return pw.Column(
      children: [
        Header(order, false, fontSize, printingType),
        OrderCommentComment(comment: order.orderComment, fontSize: fontSize),
        CartItems(order, cartMap, isKitchenCopy: true, fontSize: fontSize),
        DocketSeparator(),
        InternalID(order: order, fontSize: fontSize),
        DocketSeparator(),
        KlikitComment(comment: order.klikitComment, fontSize: fontSize),
        Footer(fontSize: fontSize),
      ],
    );
  }
}
