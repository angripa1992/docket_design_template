import 'package:docket_design_template/model/font_size.dart';
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
            costName: 'Subtotal:',
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
              costName: 'Delivery Fee:',
              amount: order.deliveryFee,
              fontSize: fontSize,
            ),
          if (order.providerAdditionalFee > 0)
            _getSubtotalItem(
              costName: 'Additional Fee:',
              amount: order.providerAdditionalFee,
              fontSize: fontSize,
            ),
          if (order.restaurantServiceFee > 0)
            _getSubtotalItem(
              costName: 'Restaurant Service Fee:',
              amount: order.restaurantServiceFee,
              fontSize: fontSize,
            ),
          // if paidByCustomer is true then show service fee else not show
          if (order.serviceFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.serviceFee > 0)
            _getSubtotalItem(
              costName: 'Service Fee:',
              amount: order.serviceFee,
              fontSize: fontSize,
            ),
          if (order.gatewayFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.gatewayFee > 0)
            _getSubtotalItem(
              costName: 'Processing Fee:',
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
          if (order.discount > 0)
            _getSubtotalItem(
              costName: 'Discount:',
              amount: order.discount,
              isDiscount: true,
              fontSize: fontSize,
            ),
          if (order.rewardDiscount > 0)
            _getSubtotalItem(
              costName: 'Reward:',
              amount: order.rewardDiscount,
              isDiscount: true,
              fontSize: fontSize,
            ),
          if (order.roundOffAmount != 0 && order.isManualOrder)
            _getSubtotalItem(
              costName: 'Rounding Off:',
              amount: order.roundOffAmount,
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
      return 'Vat';
    }
    return 'Inc. Vat';
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
