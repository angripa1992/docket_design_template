import 'package:docket_design_template/model/cart.dart';
import 'package:docket_design_template/model/modifiers.dart';
import 'package:intl/intl.dart';

import '../model/order.dart';
import 'constants.dart';

class PriceCalculator {
  static String convertPrice(TemplateOrder order, num priceInCent) {
    final price = priceInCent / 100;
    return formatPrice(
      price: price,
      currencySymbol: order.currencySymbol,
      name: order.currency,
    );
  }

  static String calculateItemPrice({
    required TemplateOrder order,
    required TemplateCart cart,
  }) {
    num itemTotalPrice = num.parse(cart.price);
    if (!order.isInterceptorOrder && order.providerId != ProviderID.FOOD_PANDA) {
      num unitPrice = num.parse(cart.unitPrice);
      itemTotalPrice = unitPrice * cart.quantity;
    }
    return formatPrice(
      price: itemTotalPrice,
      currencySymbol: order.currencySymbol,
      name: order.currency,
    );
  }

  static num calculateModifierPrice({
    required TemplateOrder order,
    required TemplateModifiers modifiers,
    required int prevQuantity,
    required int itemQuantity,
  }) {
    num modifierTotalPrice = num.parse(modifiers.price);
    if (!order.isInterceptorOrder && order.providerId != ProviderID.FOOD_PANDA) {
      num unitPrice = num.parse(modifiers.unitPrice);
      modifierTotalPrice = unitPrice * modifiers.quantity * prevQuantity * itemQuantity;
    }
    return modifierTotalPrice;
  }

  static String formatPrice({
    required num price,
    required String currencySymbol,
    required String name,
  }) {
    if (name.toUpperCase() == 'IDR') {
      return NumberFormat.currency(locale: 'id', symbol: currencySymbol, decimalDigits: 0).format(price);
    } else if (name.toUpperCase() == 'JPY') {
      return NumberFormat.currency(locale: 'ja', symbol: currencySymbol, decimalDigits: 0).format(price);
    }
    return NumberFormat.currency(name: name, symbol: currencySymbol, decimalDigits: 2).format(price);
  }
}
