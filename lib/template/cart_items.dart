import 'package:docket_design_template/model/cart.dart';
import 'package:docket_design_template/model/modifiers.dart';
import 'package:docket_design_template/model/order.dart';
import 'package:docket_design_template/template/assets_manager.dart';
import 'package:docket_design_template/template/delivery_info.dart';
import 'package:docket_design_template/template/item_comment.dart';
import 'package:docket_design_template/utils/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/font_size.dart';
import '../utils/price_calculator.dart';

class CartItems extends pw.StatelessWidget {
  final TemplateOrder order;
  final bool isKitchenCopy;
  final Map<int, List<TemplateCart>> cartMap;
  final PrinterFonts fontSize;

  CartItems(this.order, this.cartMap, {required this.isKitchenCopy, required this.fontSize});

  @override
  pw.Widget build(pw.Context context) {
    return pw.ListView.builder(
      itemCount: order.brands.length,
      itemBuilder: (_, brandIndex) {
        final cartBrand = order.brands[brandIndex];
        final cartItems = cartMap[cartBrand.id];
        return pw.Column(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.regular),
              child: DeliveryInfo(
                order: order,
                brand: cartBrand,
                quantity: cartItems!.length,
                fontSize: fontSize,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: PaddingSize.regular),
              child: pw.ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (_, cartIndex) {
                  final cartItem = cartItems[cartIndex];
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      ///cart item
                      _cartItemView(
                        cart: cartItem,
                        currencySymbol: order.currencySymbol,
                        order: order,
                        fontSize: fontSize,
                      ),

                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: cartItem.modifierGroups.map(
                          (modifiersGroupOne) {
                            return pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                ///level 1 modifiers group
                                _showModifierGroupName(
                                  name: modifiersGroupOne.name,
                                  paddingLevel: 2,
                                  fontSize: fontSize,
                                ),
                                pw.Column(
                                  children: modifiersGroupOne.modifiers.map(
                                    (modifiersOne) {
                                      return pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                                        mainAxisAlignment: pw.MainAxisAlignment.start,
                                        children: [
                                          ///level 1 modifiers
                                          _modifierItemView(
                                            groupName: modifiersGroupOne.name,
                                            modifiers: modifiersOne,
                                            prevQuantity: 1,
                                            itemQuantity: cartItem.quantity,
                                            paddingLevel: 3,
                                            order: order,
                                            fontSize: fontSize,
                                          ),
                                          pw.Column(
                                            children: modifiersOne.modifierGroups.map(
                                              (secondModifierGroups) {
                                                return pw.Column(
                                                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                                  children: [
                                                    ///level 2 modifiers group
                                                    _showModifierGroupName(
                                                      name: secondModifierGroups.name,
                                                      paddingLevel: 4,
                                                      fontSize: fontSize,
                                                    ),
                                                    pw.Column(
                                                      children: secondModifierGroups.modifiers.map(
                                                        (secondModifier) {
                                                          return _modifierItemView(
                                                            groupName: secondModifierGroups.name,
                                                            modifiers: secondModifier,
                                                            prevQuantity: modifiersOne.quantity,
                                                            itemQuantity: cartItem.quantity,
                                                            paddingLevel: 5,
                                                            order: order,
                                                            fontSize: fontSize,
                                                          );
                                                        },
                                                      ).toList(),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ).toList(),
                                          ),
                                        ],
                                      );
                                    },
                                  ).toList(),
                                ),
                              ],
                            );
                          },
                        ).toList(),
                      ),

                      ///comment
                      ItemComment(comment: cartItem.comment, fontSize: fontSize),
                    ],
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

  pw.Widget _cartItemView({
    required TemplateCart cart,
    required String currencySymbol,
    required TemplateOrder order,
    required PrinterFonts fontSize,
  }) {
    final textStyle = pw.TextStyle(
      color: PdfColors.black,
      fontSize: fontSize.mediumFontSize,
      font: AssetsManager().fontBold,
      fontFallback: AssetsManager().fontBoldFallback,
    );
    return pw.Row(
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Row(children: [
            pw.Text(
              '${cart.quantity}x',
              style: textStyle,
            ),
            pw.SizedBox(width: PaddingSize.small),
            pw.Expanded(
              child: pw.Text(
                cart.name,
                style: textStyle,
              ),
            ),
          ]),
        ),
        if (!isKitchenCopy)
          pw.Expanded(
            flex: 2,
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                PriceCalculator.calculateItemPrice(order: order, cart: cart),
                style: textStyle,
              ),
            ),
          ),
      ],
    );
  }

  pw.Widget _modifierItemView({
    required String groupName,
    required TemplateModifiers modifiers,
    required int prevQuantity,
    required int itemQuantity,
    required int paddingLevel,
    required TemplateOrder order,
    required PrinterFonts fontSize,
  }) {
    final modifierPrice = PriceCalculator.calculateModifierPrice(
      order: order,
      modifiers: modifiers,
      prevQuantity: prevQuantity,
      itemQuantity: itemQuantity,
    );
    final textStyle = pw.TextStyle(
      color: PdfColors.black,
      fontSize: fontSize.regularFontSize,
      font: AssetsManager().fontRegular,
      fontFallback: AssetsManager().fontRegularFallback,
    );
    return pw.Row(
      children: [
        pw.Expanded(
            flex: 3,
            child: pw.Padding(
              padding: pw.EdgeInsets.only(left: (PaddingSize.large * paddingLevel)),
              child: pw.Row(
                children: [
                  if (order.providerId == ProviderID.KLIKIT)
                    pw.Text(
                      '${modifiers.quantity}x',
                      style: textStyle,
                    ),
                  if (order.providerId == ProviderID.KLIKIT) pw.SizedBox(width: PaddingSize.small),
                  pw.Expanded(
                    child: pw.Text(
                      modifiers.name,
                      style: textStyle,
                    ),
                  ),
                ],
              ),
            )),
        if (!isKitchenCopy && modifierPrice > 0 && order.providerId != ProviderID.FOOD_PANDA)
          pw.Expanded(
            flex: 2,
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                PriceCalculator.formatPrice(
                  price: modifierPrice,
                  currencySymbol: order.currencySymbol,
                  name: order.currency,
                ),
                style: textStyle,
              ),
            ),
          ),
      ],
    );
  }

  pw.Widget _showModifierGroupName({
    required String name,
    required int paddingLevel,
    required PrinterFonts fontSize,
  }) {
    if (name.isEmpty) {
      return pw.SizedBox();
    }
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(
        horizontal: (PaddingSize.large * paddingLevel),
      ),
      child: pw.Text(
        name,
        style: pw.TextStyle(
          color: PdfColors.black,
          fontSize: fontSize.regularFontSize,
          font: AssetsManager().fontRegular,
          fontFallback: AssetsManager().fontRegularFallback,
        ),
      ),
    );
  }
}
