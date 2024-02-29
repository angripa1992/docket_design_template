import 'package:docket_design_template/extensions.dart';
import 'package:docket_design_template/model/order.dart';
import 'package:docket_design_template/string_keys.dart';
import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/utils/constants.dart';
import 'package:docket_design_template/utils/order_info_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/font_size.dart';
import '../utils/date_time_provider.dart';
import '../utils/printer_configuration.dart';

class Header extends pw.StatelessWidget {
  final TemplateOrder order;
  final bool isConsumerCopy;
  final PrinterFonts fontSize;
  final PrintingType printingType;

  Header(
    this.order,
    this.isConsumerCopy,
    this.fontSize,
    this.printingType,
  );

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        //order date

        pw.Text(
          '${StringKeys.order_date.tr()}: ${DateTimeProvider.orderCreatedDate(order.createdAt)} ${StringKeys.at.tr()} ${DateTimeProvider.orderCreatedTime(order.createdAt)}',
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: fontSize.mediumFontSize,
            font: AssetsManager().fontMedium,
            fontFallback: AssetsManager().fontMediumFallback,
          ),
        ),

        //queue number

        if (!isConsumerCopy && order.queueNo.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.regular),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    '${StringKeys.queue_no.tr()}: ',
                    style: pw.TextStyle(
                      color: PdfColors.black,
                      fontSize: fontSize.extraLargeFontSize,
                      font: AssetsManager().fontBold,
                      fontFallback: AssetsManager().fontBoldFallback,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      order.queueNo,
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: fontSize.extraLargeFontSize,
                        font: AssetsManager().fontBold,
                        fontFallback: AssetsManager().fontBoldFallback,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        //order id

        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.regular),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  order.placedOn,
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: fontSize.extraLargeFontSize,
                    font: AssetsManager().fontBold,
                    fontFallback: AssetsManager().fontBoldFallback,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    (order.providerId == ProviderID.KLIKIT) ? '#${order.id}' : '#${order.shortId}',
                    style: pw.TextStyle(
                      color: PdfColors.black,
                      fontSize: fontSize.extraLargeFontSize,
                      font: AssetsManager().fontBold,
                      fontFallback: AssetsManager().fontBoldFallback,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (order.status != OrderStatus.CANCELLED && order.status != OrderStatus.DELIVERED && order.status != OrderStatus.PICKED_UP)
          pw.Text(
            '${StringKeys.customer_name.tr()}: ${order.userFirstName} ${order.userLastName}',
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontMedium,
              fontFallback: AssetsManager().fontMediumFallback,
            ),
          ),
        if (order.tableNo.isNotEmpty)
          pw.Text(
            '${StringKeys.table_no.tr()}: #${order.tableNo}',
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontMedium,
              fontFallback: AssetsManager().fontMediumFallback,
            ),
          ),
        if (order.deliveryTime.isNotEmpty)
          pw.Text(
            '${StringKeys.delivery_time.tr()}: ${order.deliveryTime}',
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontMedium,
              fontFallback: AssetsManager().fontMediumFallback,
            ),
          ),

        if (order.isMerchantDelivery && order.deliveryAddress.isNotEmpty)
          pw.Text(
            '${StringKeys.delivery_address.tr()}: ${order.deliveryAddress}',
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontMedium,
              fontFallback: AssetsManager().fontMediumFallback,
            ),
          ),

        if (order.providerId == ProviderID.KLIKIT)
          pw.Text(
            '${StringKeys.payment_status.tr()}: ${OrderInfoProvider().paymentStatus(order.paymentStatus)}',
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontMedium,
              fontFallback: AssetsManager().fontMediumFallback,
            ),
          ),

        if ((order.providerId == ProviderID.KLIKIT && order.paymentStatus == PaymentStatus.paid) || (order.providerId == ProviderID.UBER_EATS && order.paymentMethod > 0))
          pw.Text(
            '${StringKeys.payment_method.tr()}: ${OrderInfoProvider().paymentMethod(order.paymentMethod)}',
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontMedium,
              fontFallback: AssetsManager().fontMediumFallback,
            ),
          ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(
            bottom: PaddingSize.regular,
          ),
          child: pw.Text(
            '${StringKeys.long_id.tr()}:  #${order.externalId}',
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.mediumFontSize,
              font: AssetsManager().fontRegular,
              fontFallback: AssetsManager().fontRegularFallback,
            ),
          ),
        ),
        pw.Text(
          '${StringKeys.branch_name.tr()}: ${order.branchName}',
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: fontSize.regularFontSize,
            font: AssetsManager().fontRegular,
            fontFallback: AssetsManager().fontRegularFallback,
          ),
        ),
        if (isConsumerCopy)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.medium),
            child: pw.Text(
              StringKeys.note_to_customer.tr(),
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: fontSize.regularFontSize,
                font: AssetsManager().fontRegular,
                fontFallback: AssetsManager().fontRegularFallback,
              ),
            ),
          ),
        if (printingType == PrintingType.manual)
          pw.Text(
            '${StringKeys.order_status.tr()}: ${OrderInfoProvider().orderStatus(order.status)}',
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.regularFontSize,
              font: AssetsManager().fontSemiBold,
              fontFallback: AssetsManager().fontSemiBoldFallback,
            ),
          ),
        if (order.pickupAt.isNotEmpty)
          pw.Text(
            '${StringKeys.estimated_pickup_time.tr()}: ${order.pickupAt}',
            style: pw.TextStyle(
              color: PdfColors.black,
              fontSize: fontSize.regularFontSize,
              font: AssetsManager().fontSemiBold,
              fontFallback: AssetsManager().fontSemiBoldFallback,
            ),
          ),
      ],
    );
  }
}
