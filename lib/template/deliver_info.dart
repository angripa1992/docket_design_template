import 'package:docket_design_template/extensions.dart';
import 'package:docket_design_template/string_keys.dart';
import 'package:docket_design_template/utils/date_time_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/font_size.dart';
import '../model/order.dart';
import '../utils/constants.dart';
import 'assets_manager.dart';

class DeliverInfo extends pw.StatelessWidget {
  final TemplateOrder order;
  final PrinterFonts fontSize;

  DeliverInfo({required this.order, required this.fontSize,});

  @override
  pw.Widget build(pw.Context context) {
    final textStyle = pw.TextStyle(
      fontSize: fontSize.regularFontSize,
      color: PdfColors.black,
      font: AssetsManager().fontRegular,
      fontFallback: AssetsManager().fontRegularFallback,
    );
    return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.regular),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if(order.fulfillmentExpectedPickupTime.isNotEmpty)
              pw.Text(
                '${StringKeys.pickup_time.tr()}: ${DateTimeProvider.pickupTime(order.fulfillmentExpectedPickupTime)}',
                style: textStyle,
              ),
            if(order.fulfillmentRider != null && order.fulfillmentRider?.name != null)
              pw.Text(
                '${StringKeys.driver_name.tr()}: ${order.fulfillmentRider!.name}',
                style: textStyle,
              ),
            if(order.fulfillmentRider != null && order.fulfillmentRider?.phone != null)
              pw.Text(
                '${StringKeys.driver_phone.tr()}: ${order.fulfillmentRider!.phone}',
                style: textStyle,
              ),
            if(order.fulfillmentRider != null && order.fulfillmentRider?.licensePlate != null)
              pw.Text(
                '${StringKeys.license_plate.tr()}: ${order.fulfillmentRider!.licensePlate}',
                style: textStyle,
              ),
          ]
      )
    );
  }
}
