import 'package:docket_design_template/extensions.dart';
import 'package:docket_design_template/model/font_size.dart';
import 'package:docket_design_template/string_keys.dart';
import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/template/total_price.dart';
import 'package:docket_design_template/utils/constants.dart';
import 'package:docket_design_template/utils/price_calculator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/order.dart';

class PriceDetails extends pw.StatelessWidget {
  final TemplateOrder order;
  final PrinterFonts fontSize;

  PriceDetails({required this.order, required this.fontSize});

  @override
  pw.Widget build(pw.Context context) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.regular),
      child: pw.Column(
        children: [
          _getSubtotalItem(
            costName: '${StringKeys.subtotal.tr()}:',
            amount: order.providerSubTotal,
            isSubTotal: true,
            fontSize: fontSize,
          ),
          if (order.vat > 0)
            _getSubtotalItem(
              costName: _vatTitle(),
              amount: order.vat,
              fontSize: fontSize,
            ),
          if (order.deliveryFee > 0)
            _getSubtotalItem(
              costName: '${StringKeys.delivery_fee.tr()}:',
              amount: order.deliveryFee,
              fontSize: fontSize,
            ),
          if (order.providerAdditionalFee > 0)
            _getSubtotalItem(
              costName: '${StringKeys.additional_fee.tr()}:',
              amount: order.providerAdditionalFee,
              fontSize: fontSize,
            ),
          if (order.restaurantServiceFee > 0)
            _getSubtotalItem(
              costName: '${StringKeys.restaurant_service_fee.tr()}:',
              amount: order.restaurantServiceFee,
              fontSize: fontSize,
            ),
          // if paidByCustomer is true then show service fee else not show
          if (order.serviceFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.serviceFee > 0)
            _getSubtotalItem(
              costName: '${StringKeys.service_fee.tr()}:',
              amount: order.serviceFee,
              fontSize: fontSize,
            ),
          if (order.gatewayFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.gatewayFee > 0)
            _getSubtotalItem(
              costName: '${StringKeys.processing_fee.tr()}:',
              amount: order.gatewayFee,
              fontSize: fontSize,
            ),
          if (order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.paidByCustomer && order.mergeFee > 0)
            _getSubtotalItem(
              costName: '${order.mergeFeeTitle}:',
              amount: order.mergeFee,
              fontSize: fontSize,
            ),
          if (order.customFee > 0)
            _getSubtotalItem(
              costName: '${order.customFeeTitle}:',
              amount: order.customFee,
              fontSize: fontSize,
            ),
          if (order.customerDiscount > 0)
            _getSubtotalItem(
              costName: '${StringKeys.discount.tr()}:',
              amount: order.customerDiscount,
              isDiscount: true,
              fontSize: fontSize,
            ),
          if (order.rewardDiscount > 0)
            _getSubtotalItem(
              costName: '${StringKeys.reward.tr()}:',
              amount: order.rewardDiscount,
              isDiscount: true,
              fontSize: fontSize,
            ),
          if (order.roundOffAmount != 0 || order.providerRoundOffAmount != 0)
            _getSubtotalItem(
              costName: '${StringKeys.reward.tr()}:',
              amount: order.isManualOrder ? order.roundOffAmount : order.providerRoundOffAmount,
              fontSize: fontSize,
              isRoundOff: true,
            ),
          TotalPrice(order: order, fontSize: fontSize),
        ],
      ),
    );
  }

  String _vatTitle() {
    if (order.providerId == ProviderID.FOOD_PANDA && !order.isInterceptorOrder && !order.isVatIncluded) {
      return StringKeys.vat.tr();
    }
    return StringKeys.inc_vat.tr();
  }

  pw.Widget _getSubtotalItem({
    required String costName,
    required num amount,
    required PrinterFonts fontSize,
    bool isDiscount = false,
    bool isSubTotal = false,
    bool isRoundOff = false,
  }) {
    final textStyle = pw.TextStyle(
      color: PdfColors.black,
      fontSize: fontSize.regularFontSize,
      font: AssetsManager().fontRegular,
      fontFallback: AssetsManager().fontRegularFallback,
    );
    final subTotalTextStyle = pw.TextStyle(
      color: PdfColors.black,
      fontSize: fontSize.mediumFontSize,
      font: AssetsManager().fontMedium,
      fontFallback: AssetsManager().fontMediumFallback,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          costName,
          style: isSubTotal ? subTotalTextStyle : textStyle,
        ),
        pw.Text(
          isRoundOff ? '${order.currencySymbol} ${amount.isNegative ? '' : '+'}${amount / 100}' : '${isDiscount ? '-' : ''}${PriceCalculator.convertPrice(order, amount)}',
          style: isSubTotal ? subTotalTextStyle : textStyle,
        ),
      ],
    );
  }
}
