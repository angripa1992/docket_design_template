import 'dart:typed_data';
import 'dart:ui';

import 'package:docket_design_template/extensions.dart';
import 'package:docket_design_template/model/brand.dart';
import 'package:docket_design_template/model/cart.dart';
import 'package:docket_design_template/model/order.dart';
import 'package:docket_design_template/string_keys.dart';
import 'package:docket_design_template/translator.dart';
import 'package:docket_design_template/utils/constants.dart';
import 'package:docket_design_template/utils/date_time_provider.dart';
import 'package:docket_design_template/utils/order_info_provider.dart';
import 'package:docket_design_template/utils/price_calculator.dart';
import 'package:docket_design_template/utils/printer_configuration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sunmi_print_ticket/sunmi_print_ticket.dart' as sunmi;
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

import 'model/modifiers.dart';

class SunmiDesignTemplate {
  static final _instance = SunmiDesignTemplate._internal();

  factory SunmiDesignTemplate() => _instance;

  SunmiDesignTemplate._internal();

  late SunmiSizeConfig _config;

  Future<bool> _bindingPrinter() async {
    final result = await SunmiPrinter.bindingPrinter();
    return result ?? false;
  }

  Future<void> printSunmi({
    required TemplateOrder order,
    // required bool isCustomerCopy,
    // required Roll roll,
    // required PrintingType printingType,
    required PrinterConfiguration printerConfiguration,
    required int fontId,
    required Locale locale,
  }) async {
    if (!await _bindingPrinter()) return;

    Translator.setLocale(locale);
    SunmiFontSize fontSize = fromId(fontId);

    _config = sunmiSizeConfigFont(printerConfiguration.roll, fontSize);
    bool isCustomerCopy = printerConfiguration.docket == Docket.customer ? true : false;

    await SunmiPrinter.initPrinter();
    await SunmiPrinter.startTransactionPrint(true);

    await generateHeader(order, isCustomerCopy, printerConfiguration.printingType, fontSize);

    if (order.orderComment.isNotEmpty) {
      await printOrderComment(order.orderComment, fontSize);
    }

    await generateCart(order, isCustomerCopy, fontSize);

    await generateSunmiSeparator();

    if (isCustomerCopy) {
      await generatePriceBreakdown(order, fontSize);

      await generateSunmiSeparator();
    }

    await generateInternalID(order, fontSize);

    await generateSunmiSeparator();

    if (isCustomerCopy && order.isThreePlOrder) {
      await generateThreePlInfo(order, fontSize);
      await generateSunmiSeparator();
    }

    if (order.klikitComment != "") {
      await printOrderComment(order.klikitComment, fontSize);
    }

    if (isCustomerCopy && order.qrInfo != null) {
      await generateQrInfo(order.qrInfo!, fontSize);
    }

    await generateFooter(fontSize);

    await SunmiPrinter.cut();

    await SunmiPrinter.exitTransactionPrint(true);
  }

  Future generateHeader(
    TemplateOrder order,
    bool isCustomerCopy,
    PrintingType printingType,
    SunmiFontSize fontSize,
  ) async {
    await SunmiPrinter.setFontSize(fontSize);
    await SunmiPrinter.printText(
      '${StringKeys.order_date.tr()}: ${DateTimeProvider.orderCreatedDate(order.createdAt)} ${StringKeys.at.tr()} ${DateTimeProvider.orderCreatedTime(order.createdAt)}',
    );
    await SunmiPrinter.resetFontSize();

    await SunmiPrinter.setFontSize(fontSize);
    await SunmiPrinter.bold();
    if (!isCustomerCopy && order.queueNo.isNotEmpty) {
      await printRow(
        '${StringKeys.queue_no.tr()}: ',
        order.queueNo,
      );
    }

    await SunmiPrinter.resetFontSize();

    await SunmiPrinter.setFontSize(fontSize);
    await printRow(
      order.placedOn,
      order.providerId == ProviderID.KLIKIT ? '#${order.id}' : '#${order.shortId}',
    );
    await SunmiPrinter.resetFontSize();
    await SunmiPrinter.resetBold();

    if (order.status != OrderStatus.CANCELLED && order.status != OrderStatus.DELIVERED && order.status != OrderStatus.PICKED_UP) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText(
        '${StringKeys.customer_name.tr()}: ${order.userFirstName} ${order.userLastName}',
      );
      await SunmiPrinter.resetFontSize();
    }

    if (order.tableNo.isNotEmpty) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText('${StringKeys.table_no.tr()}: #${order.tableNo}');
      await SunmiPrinter.resetFontSize();
    }

    if (order.deliveryTime.isNotEmpty) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText('${StringKeys.delivery_time.tr()}: ${order.deliveryTime}');
      await SunmiPrinter.resetFontSize();
    }

    if (order.isMerchantDelivery && order.deliveryAddress.isNotEmpty) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText('${StringKeys.delivery_address.tr()}: ${order.deliveryAddress}');
      await SunmiPrinter.resetFontSize();
    }

    if (order.providerId == ProviderID.KLIKIT) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText('${StringKeys.payment_status.tr()}:  #${OrderInfoProvider().paymentStatus(order.paymentStatus)}');
      await SunmiPrinter.resetFontSize();
    }

    if ((order.providerId == ProviderID.KLIKIT && order.paymentStatus == PaymentStatus.paid) || (order.providerId == ProviderID.UBER_EATS && order.paymentMethod > 0)) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText('${StringKeys.payment_method.tr()}:  #${OrderInfoProvider().paymentMethod(order.paymentMethod)}');
      await SunmiPrinter.resetFontSize();
    }

    await SunmiPrinter.setFontSize(fontSize);
    await SunmiPrinter.printText('${StringKeys.long_id.tr()}:  #${order.externalId}');
    await SunmiPrinter.resetFontSize();

    await SunmiPrinter.setFontSize(fontSize);
    await SunmiPrinter.printText('${StringKeys.branch_name.tr()}: ${order.branchName}');
    await SunmiPrinter.resetFontSize();

    if (isCustomerCopy) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText(StringKeys.note_to_customer.tr());
      await SunmiPrinter.resetFontSize();
    }

    if (printingType == PrintingType.manual) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText('${StringKeys.order_status.tr()}: ${OrderInfoProvider().orderStatus(order.status)}');
      await SunmiPrinter.resetFontSize();
    }

    if (order.pickupAt.isNotEmpty) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText('${StringKeys.estimated_pickup_time.tr()}: ${order.pickupAt}');
      await SunmiPrinter.resetFontSize();
    }
  }

  Future getDeliveryInfo(
    TemplateCartBrand brand,
    int itemCount,
    String orderType,
    SunmiFontSize fontSize,
  ) async {
    await generateSunmiSeparator();
    await SunmiPrinter.setFontSize(fontSize);
    await SunmiPrinter.printText(brand.title);
    await SunmiPrinter.resetFontSize();

    await SunmiPrinter.setFontSize(fontSize);
    await printRow(
      "$itemCount ${StringKeys.item.tr().toLowerCase()}${itemCount > 1 ? '(s)' : ''}",
      orderType,
    );
    await SunmiPrinter.resetFontSize();
    await generateSunmiSeparator();
  }

  Future generateCart(TemplateOrder order, bool isCustomerCopy, SunmiFontSize fontSize) async {
    for (int i = 0; i < order.brands.length; i++) {
      int cnt = 0;
      for (int j = 0; j < order.cartV2.length; j++) {
        if (order.brands[i].id == order.cartV2[j].cartBrand.id) {
          cnt++;
        }
      }

      await getDeliveryInfo(order.brands[i], cnt, getOrderType(order), fontSize);

      for (int j = 0; j < order.cartV2.length; j++) {
        if (order.brands[i].id == order.cartV2[j].cartBrand.id) {
          TemplateCart cart = order.cartV2[j];

          await getItem(
            order: order,
            cart: cart,
            isCustomerCopy: isCustomerCopy,
            fontSize: fontSize,
          );
          await generateFirstGroupModifier(
            itemQuantity: cart.quantity,
            groups: cart.modifierGroups,
            order: order,
            isCustomerCopy: isCustomerCopy,
            fontSize: fontSize,
          );
          if (cart.comment.isNotEmpty) {
            await printItemNote(cart.comment, fontSize);
          }
        }
      }
    }
  }

  Future getItem({
    required TemplateOrder order,
    required TemplateCart cart,
    required bool isCustomerCopy,
    required SunmiFontSize fontSize,
  }) async {
    final itemPrice = PriceCalculator.calculateItemPrice(order: order, cart: cart);
    await SunmiPrinter.bold();
    await SunmiPrinter.setFontSize(fontSize);
    isCustomerCopy
        ? await printRow(
            "${cart.quantity}X${cart.name}",
            isCustomerCopy ? itemPrice : "",
          )
        : await SunmiPrinter.printText('${cart.quantity}X${cart.name}');
    await SunmiPrinter.resetFontSize();
    await SunmiPrinter.resetBold();
  }

  Future printItemNote(String itemNote, SunmiFontSize fontSize) async {
    await SunmiPrinter.bold();
    await SunmiPrinter.setFontSize(fontSize);
    await SunmiPrinter.printText('${StringKeys.note.tr()}: $itemNote');
    await SunmiPrinter.resetFontSize();
    await SunmiPrinter.resetBold();
  }

  Future generateFirstGroupModifier({
    required int itemQuantity,
    required List<TemplateModifierGroups> groups,
    required TemplateOrder order,
    required bool isCustomerCopy,
    required SunmiFontSize fontSize,
  }) async {
    for (int grp = 0; grp < groups.length; grp++) {
      await getGroup(groups[grp].name, 1, fontSize);
      for (int mod = 0; mod < groups[grp].modifiers.length; mod++) {
        TemplateModifiers modifiers = groups[grp].modifiers[mod];
        await getModifier(
          itemQuantity: itemQuantity,
          prevQuantity: 1,
          modifiers: modifiers,
          order: order,
          space: 2,
          isCustomerCopy: isCustomerCopy,
          fontSize: fontSize,
        );

        await generateSecondGroupModifier(
          itemQuantity: itemQuantity,
          prevQuantity: modifiers.quantity,
          groups: modifiers.modifierGroups,
          order: order,
          isCustomerCopy: isCustomerCopy,
          fontSize: fontSize,
        );
      }
    }
  }

  Future generateSecondGroupModifier({
    required int itemQuantity,
    required int prevQuantity,
    required List<TemplateModifierGroups> groups,
    required TemplateOrder order,
    required bool isCustomerCopy,
    required SunmiFontSize fontSize,
  }) async {
    for (int grp = 0; grp < groups.length; grp++) {
      await getGroup(groups[grp].name, 2, fontSize);
      for (int mod1 = 0; mod1 < groups[grp].modifiers.length; mod1++) {
        TemplateModifiers modifiers = groups[grp].modifiers[mod1];
        await getModifier(
          itemQuantity: itemQuantity,
          prevQuantity: prevQuantity,
          modifiers: modifiers,
          order: order,
          space: 4,
          isCustomerCopy: isCustomerCopy,
          fontSize: fontSize,
        );
      }
    }
  }

  Future getModifier({
    required int itemQuantity,
    required int prevQuantity,
    required TemplateModifiers modifiers,
    required TemplateOrder order,
    required int space,
    required isCustomerCopy,
    required SunmiFontSize fontSize,
  }) async {
    final modifierPrice = PriceCalculator.calculateModifierPrice(
      order: order,
      modifiers: modifiers,
      prevQuantity: prevQuantity,
      itemQuantity: itemQuantity,
    );
    final priceStr = PriceCalculator.formatPrice(
      price: modifierPrice,
      currencySymbol: order.currencySymbol,
      name: order.currency,
    );
    await SunmiPrinter.setFontSize(fontSize);
    isCustomerCopy
        ? await SunmiPrinter.printRow(cols: [
            ColumnMaker(
              text: " ",
              align: SunmiPrintAlign.LEFT,
              width: space,
            ),
            ColumnMaker(
              text: "${modifiers.quantity}X ${modifiers.name}",
              align: SunmiPrintAlign.LEFT,
              width: _config.left - space,
            ),
            if (modifierPrice > 0 && order.providerId != ProviderID.FOOD_PANDA)
              ColumnMaker(
                text: isCustomerCopy ? priceStr : "",
                align: SunmiPrintAlign.RIGHT,
                width: _config.right,
              )
          ])
        : await SunmiPrinter.printText("${printSpaces(space)}${modifiers.quantity}X ${modifiers.name}");
    await SunmiPrinter.resetFontSize();
  }

  Future getGroup(String groupName, int space, SunmiFontSize fontSize) async {
    await SunmiPrinter.setFontSize(fontSize);
    await printRow(" ", groupName);
    await SunmiPrinter.resetFontSize();
  }

  Future generatePriceBreakdown(TemplateOrder order, SunmiFontSize fontSize) async {
    await getPriceBreakdown(
      costName: '${StringKeys.subtotal.tr()}:',
      amount: order.providerSubTotal,
      isSubTotal: true,
      order: order,
      fontSize: fontSize,
    );
    if (order.vat > 0) {
      await getPriceBreakdown(
        costName: _vatTitle(order),
        amount: order.vat,
        order: order,
        fontSize: fontSize,
      );
    }
    if (order.deliveryFee > 0) {
      await getPriceBreakdown(
        costName: '${StringKeys.delivery_fee.tr()}:',
        amount: order.deliveryFee,
        order: order,
        fontSize: fontSize,
      );
    }
    if (order.providerAdditionalFee > 0) {
      await getPriceBreakdown(
        costName: '${StringKeys.additional_fee.tr()}:',
        amount: order.providerAdditionalFee,
        order: order,
        fontSize: fontSize,
      );
    }
    if (order.restaurantServiceFee > 0) {
      await getPriceBreakdown(
        costName: '${StringKeys.restaurant_service_fee.tr()}:',
        amount: order.restaurantServiceFee,
        order: order,
        fontSize: fontSize,
      );
    }
    // if paidByCustomer is true then show service fee and processing fee else not show
    if (order.serviceFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.serviceFee > 0) {
      await getPriceBreakdown(
        costName: '${StringKeys.service_fee.tr()}:',
        amount: order.serviceFee,
        order: order,
        fontSize: fontSize,
      );
    }
    if (order.gatewayFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.gatewayFee > 0) {
      await getPriceBreakdown(
        costName: '${StringKeys.processing_fee.tr()}:',
        amount: order.gatewayFee,
        order: order,
        fontSize: fontSize,
      );
    }
    if (order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.paidByCustomer && order.mergeFee > 0) {
      await getPriceBreakdown(
        costName: '${order.mergeFeeTitle}:',
        amount: order.mergeFee,
        order: order,
        fontSize: fontSize,
      );
    }
    if (order.customFee > 0) {
      await getPriceBreakdown(
        costName: '${order.customFeeTitle}:',
        amount: order.customFee,
        order: order,
        fontSize: fontSize,
      );
    }
    if (order.customerDiscount > 0) {
      await getPriceBreakdown(
        costName: '${StringKeys.discount.tr()}:',
        amount: order.customerDiscount,
        isDiscount: true,
        order: order,
        fontSize: fontSize,
      );
    }
    if (order.rewardDiscount > 0) {
      await getPriceBreakdown(
        costName: '${StringKeys.reward.tr()}:',
        amount: order.rewardDiscount,
        isDiscount: true,
        order: order,
        fontSize: fontSize,
      );
    }
    if (order.roundOffAmount != 0 || order.providerRoundOffAmount != 0) {
      await getPriceBreakdown(
        costName: '${StringKeys.reward.tr()}:',
        amount: order.isManualOrder ? order.roundOffAmount : order.providerRoundOffAmount,
        order: order,
        isRoundOff: true,
        fontSize: fontSize,
      );
    }
    await getPriceBreakdown(costName: '${StringKeys.total.tr()}:', amount: order.providerGrandTotal, isTotal: true, order: order, fontSize: fontSize);
  }

  Future getPriceBreakdown({
    required TemplateOrder order,
    required String costName,
    required num amount,
    bool isDiscount = false,
    bool isSubTotal = false,
    bool isTotal = false,
    bool isRoundOff = false,
    required SunmiFontSize fontSize,
  }) async {
    await SunmiPrinter.setFontSize(fontSize);
    if (isTotal) {
      await SunmiPrinter.bold();
    }

    String value = isRoundOff ? '${order.currencySymbol} ${amount.isNegative ? '' : '+'}${amount / 100}' : '${isDiscount ? '-' : ''}${PriceCalculator.convertPrice(order, amount)}';
    await printRow(costName, value);

    if (isTotal) {
      await SunmiPrinter.resetBold();
    }
    await SunmiPrinter.resetFontSize();
  }

  Future generateInternalID(TemplateOrder order, SunmiFontSize fontSize) async {
    await SunmiPrinter.bold();
    await SunmiPrinter.setFontSize(fontSize);
    await printRow(StringKeys.internal_id.tr().toUpperCase(), '#${order.id}');
    await SunmiPrinter.resetFontSize();
    await SunmiPrinter.resetBold();
  }

  Future generateQrInfo(QrInfo qrInfo, SunmiFontSize fontSize) async {
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.setFontSize(fontSize);
    await SunmiPrinter.printText(qrInfo.qrLabel);
    await SunmiPrinter.resetFontSize();

    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printQRCode(qrInfo.qrContent);
  }

  Future generateFooter(SunmiFontSize fontSize) async {
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.setFontSize(fontSize);
    await SunmiPrinter.printText(StringKeys.powered_by.tr());
    await SunmiPrinter.resetFontSize();

    Uint8List byte = await _getImageFromAsset('packages/docket_design_template/assets/images/app_logo.jpg');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printImage(byte);

    await SunmiPrinter.lineWrap(1);

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.setFontSize(fontSize);
    await SunmiPrinter.printText('klikit');
    await SunmiPrinter.resetFontSize();
    await SunmiPrinter.lineWrap(2);
  }

  Future printOrderComment(String comment, SunmiFontSize fontSize) async {
    await SunmiPrinter.bold();
    await SunmiPrinter.setFontSize(fontSize);
    await SunmiPrinter.printText("${StringKeys.note.tr()}: $comment");
    await SunmiPrinter.resetFontSize();
    await SunmiPrinter.resetBold();
  }

  Future generateThreePlInfo(TemplateOrder order, SunmiFontSize fontSize) async {
    if (order.fulfillmentExpectedPickupTime.isNotEmpty) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText(
        '${StringKeys.pickup_time.tr()}: ${DateTimeProvider.pickupTime(order.fulfillmentExpectedPickupTime)}',
      );
      await SunmiPrinter.resetFontSize();
    }

    if (order.fulfillmentRider != null && order.fulfillmentRider?.name != null) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText(
        '${StringKeys.driver_name.tr()}: ${order.fulfillmentRider!.name}',
      );
      await SunmiPrinter.resetFontSize();
    }

    if (order.fulfillmentRider != null && order.fulfillmentRider?.phone != null) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText(
        '${StringKeys.driver_phone.tr()}: ${order.fulfillmentRider!.phone}',
      );
      await SunmiPrinter.resetFontSize();
    }

    if (order.fulfillmentRider != null && order.fulfillmentRider?.phone != null) {
      await SunmiPrinter.setFontSize(fontSize);
      await SunmiPrinter.printText(
        '${StringKeys.license_plate.tr()}: ${order.fulfillmentRider!.licensePlate}',
      );
      await SunmiPrinter.resetFontSize();
    }
    await SunmiPrinter.setFontSize(fontSize);
    await SunmiPrinter.printText(
      '${StringKeys.pickup_time.tr()}: ${DateTimeProvider.pickupTime(order.fulfillmentExpectedPickupTime)}',
    );
    await SunmiPrinter.resetFontSize();
  }

  Future generateSunmiSeparator() async {
    await SunmiPrinter.line();
  }

  String getOrderType(TemplateOrder order) {
    if (order.type == OrderType.DELIVERY) {
      return 'Delivery';
    } else if (order.type == OrderType.PICKUP) {
      return 'Pickup';
    } else if (order.type == OrderType.DINE_IN) {
      return 'Dine In';
    } else {
      return 'Manual';
    }
  }

  Future<Uint8List> readFileBytes(String path) async {
    ByteData fileData = await rootBundle.load(path);
    Uint8List fileUnit8List = fileData.buffer.asUint8List(fileData.offsetInBytes, fileData.lengthInBytes);
    return fileUnit8List;
  }

  Future<Uint8List> _getImageFromAsset(String iconPath) async {
    return await readFileBytes(iconPath);
  }

  String _vatTitle(TemplateOrder order) {
    if (order.providerId == ProviderID.FOOD_PANDA && !order.isInterceptorOrder && !order.isVatIncluded) {
      return StringKeys.vat.tr();
    }
    return StringKeys.inc_vat.tr();
  }

  String printSpaces(int value) {
    return ' ' * value; // Notice the space character within the single quotes
  }

  SunmiFontSize fromId(int fontId) {
    switch (fontId) {
      case PrinterFontSize.small:
        return SunmiFontSize.SM;
      case PrinterFontSize.normal:
        return SunmiFontSize.MD;
      case PrinterFontSize.large:
        return SunmiFontSize.LG;
      case PrinterFontSize.huge:
        return SunmiFontSize.LG;
      default:
        return SunmiFontSize.MD;
    }
  }

  Future printRow(String label, String value) async {
    if (Translator.getLocale().languageCode == 'th') {
      await sunmi.SunmiPrinter.bindPrinterService();
      // width: 10 Width of column , 0 - LEFT, 1 - CENTER, 2 - RIGHT
      await sunmi.SunmiPrinter.printTable(cols: [
        sunmi.ColumnMaker(text: label, width: _config.left, align: 0),
        sunmi.ColumnMaker(text: value, width: _config.right, align: 2),
      ]);
      await sunmi.SunmiPrinter.resetFontSize();
      await sunmi.SunmiPrinter.unbindPrinterService();
    } else {
      await SunmiPrinter.printRow(cols: [
        ColumnMaker(
          text: label,
          align: SunmiPrintAlign.LEFT,
          width: _config.left,
        ),
        ColumnMaker(
          text: value,
          align: SunmiPrintAlign.RIGHT,
          width: _config.right,
        )
      ]);
    }
  }
}
