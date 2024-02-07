import 'dart:typed_data';

import 'package:docket_design_template/model/brand.dart';
import 'package:docket_design_template/model/cart.dart';
import 'package:docket_design_template/model/order.dart';
import 'package:docket_design_template/utils/constants.dart';
import 'package:docket_design_template/utils/date_time_provider.dart';
import 'package:docket_design_template/utils/order_info_provider.dart';
import 'package:docket_design_template/utils/price_calculator.dart';
import 'package:docket_design_template/utils/printer_configuration.dart';
import 'package:flutter/services.dart';
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
    required bool isCustomerCopy,
    required Roll roll,
    required PrintingType printingType,
  }) async {
    if (!await _bindingPrinter()) return;
    _config = sunmiSizeConfig(roll);
    await SunmiPrinter.initPrinter();
    await SunmiPrinter.startTransactionPrint(true);
    await generateHeader(order, isCustomerCopy, printingType);

    if (order.orderComment.isNotEmpty) {
      await printOrderComment(order.orderComment);
    }

    await generateCart(order, isCustomerCopy);

    await generateSunmiSeparator();

    if (isCustomerCopy) {
      await generatePriceBreakdown(order);

      await generateSunmiSeparator();
    }

    await generateInternalID(order);

    await generateSunmiSeparator();

    if (isCustomerCopy && order.isThreePlOrder) {
      await generateThreePlInfo(order);
      await generateSunmiSeparator();
    }

    if (order.klikitComment != "") {
      await printOrderComment(order.klikitComment);
    }

    if (order.qrInfo != null) {
      await generateQrInfo(order.qrInfo!);
    }

    await generateFooter();

    await SunmiPrinter.cut();

    await SunmiPrinter.exitTransactionPrint(true);
  }

  Future generateHeader(
    TemplateOrder order,
    bool isCustomerCopy,
    PrintingType printingType,
  ) async {
    await SunmiPrinter.printText(
      'Order Date: ${DateTimeProvider.orderCreatedDate(order.createdAt)} at ${DateTimeProvider.orderCreatedTime(order.createdAt)}',
    );

    await SunmiPrinter.bold();
    if (!isCustomerCopy && order.queueNo.isNotEmpty) {
      await SunmiPrinter.printRow(cols: [
        ColumnMaker(
          text: 'Queue No: ',
          align: SunmiPrintAlign.LEFT,
          width: _config.left,
        ),
        ColumnMaker(
          text: order.queueNo,
          align: SunmiPrintAlign.RIGHT,
          width: _config.right,
        )
      ]);
    }

    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: order.placedOn,
        align: SunmiPrintAlign.LEFT,
        width: _config.left,
      ),
      ColumnMaker(
        text: order.providerId == ProviderID.KLIKIT ? '#${order.id}' : '#${order.shortId}',
        align: SunmiPrintAlign.RIGHT,
        width: _config.right,
      )
    ]);
    await SunmiPrinter.resetBold();

    if (order.status != OrderStatus.CANCELLED && order.status != OrderStatus.DELIVERED && order.status != OrderStatus.PICKED_UP) {
      await SunmiPrinter.printText(
        'Customer Name: ${order.userFirstName} ${order.userLastName}',
      );
    }

    if (order.tableNo.isNotEmpty) {
      await SunmiPrinter.printText('Table No: #${order.tableNo}');
    }

    if (order.providerId == ProviderID.KLIKIT) {
      await SunmiPrinter.printRow(cols: [
        ColumnMaker(
          text: OrderInfoProvider().paymentStatus(order.paymentStatus),
          align: SunmiPrintAlign.LEFT,
          width: _config.left,
        ),
        ColumnMaker(
          text: OrderInfoProvider().paymentMethod(order.paymentMethod),
          align: SunmiPrintAlign.RIGHT,
          width: _config.right,
        )
      ]);
    }

    await SunmiPrinter.printText('Long ID:  #${order.externalId}');
    await SunmiPrinter.printText('Branch Name: ${order.branchName}');

    if (isCustomerCopy) {
      await SunmiPrinter.printText(Consts.customerNote);
    }

    if (printingType == PrintingType.manual) {
      await SunmiPrinter.printText('Order Status: ${OrderInfoProvider().orderStatus(order.status)}');
    }

    if (order.pickupAt.isNotEmpty) {
      await SunmiPrinter.printText('Estimated Pickup Time: ${order.pickupAt}');
    }
  }

  Future getDeliveryInfo(
    TemplateCartBrand brand,
    int itemCount,
    String orderType,
  ) async {
    await generateSunmiSeparator();
    await SunmiPrinter.printText(brand.title);
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "$itemCount item${itemCount > 1 ? '(s)' : ''}",
        align: SunmiPrintAlign.LEFT,
        width: _config.left,
      ),
      ColumnMaker(
        text: orderType,
        align: SunmiPrintAlign.RIGHT,
        width: _config.right,
      )
    ]);
    await generateSunmiSeparator();
  }

  Future generateCart(TemplateOrder order, bool isCustomerCopy) async {
    for (int i = 0; i < order.brands.length; i++) {
      int cnt = 0;
      for (int j = 0; j < order.cartV2.length; j++) {
        if (order.brands[i].id == order.cartV2[j].cartBrand.id) {
          cnt++;
        }
      }

      await getDeliveryInfo(order.brands[i], cnt, getOrderType(order));

      for (int j = 0; j < order.cartV2.length; j++) {
        if (order.brands[i].id == order.cartV2[j].cartBrand.id) {
          TemplateCart cart = order.cartV2[j];

          await getItem(
            order: order,
            cart: cart,
            isCustomerCopy: isCustomerCopy,
          );
          await generateFirstGroupModifier(
            itemQuantity: cart.quantity,
            groups: cart.modifierGroups,
            order: order,
            isCustomerCopy: isCustomerCopy,
          );
          if (cart.comment.isNotEmpty) {
            await printItemNote(cart.comment);
          }
        }
      }
    }
  }

  Future getItem({
    required TemplateOrder order,
    required TemplateCart cart,
    required bool isCustomerCopy,
  }) async {
    final itemPrice = PriceCalculator.calculateItemPrice(order: order, cart: cart);
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "${cart.quantity}X${cart.name}",
        align: SunmiPrintAlign.LEFT,
        width: _config.left,
      ),
      ColumnMaker(
        text: isCustomerCopy ? itemPrice : "",
        align: SunmiPrintAlign.RIGHT,
        width: _config.right,
      )
    ]);
    await SunmiPrinter.resetBold();
  }

  Future printItemNote(String itemNote) async {
    await SunmiPrinter.bold();
    await SunmiPrinter.printText('Note: $itemNote');
    await SunmiPrinter.resetBold();
  }

  Future generateFirstGroupModifier({
    required int itemQuantity,
    required List<TemplateModifierGroups> groups,
    required TemplateOrder order,
    required bool isCustomerCopy,
  }) async {
    for (int grp = 0; grp < groups.length; grp++) {
      await getGroup(groups[grp].name, 1);
      for (int mod = 0; mod < groups[grp].modifiers.length; mod++) {
        TemplateModifiers modifiers = groups[grp].modifiers[mod];
        await getModifier(
          itemQuantity: itemQuantity,
          prevQuantity: 1,
          modifiers: modifiers,
          order: order,
          space: 2,
          isCustomerCopy: isCustomerCopy,
        );

        await generateSecondGroupModifier(
          itemQuantity: itemQuantity,
          prevQuantity: modifiers.quantity,
          groups: modifiers.modifierGroups,
          order: order,
          isCustomerCopy: isCustomerCopy,
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
  }) async {
    for (int grp = 0; grp < groups.length; grp++) {
      await getGroup(groups[grp].name, 2);
      for (int mod1 = 0; mod1 < groups[grp].modifiers.length; mod1++) {
        TemplateModifiers modifiers = groups[grp].modifiers[mod1];
        await getModifier(
          itemQuantity: itemQuantity,
          prevQuantity: prevQuantity,
          modifiers: modifiers,
          order: order,
          space: 4,
          isCustomerCopy: isCustomerCopy,
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
    await SunmiPrinter.printRow(cols: [
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
    ]);
  }

  Future getGroup(String groupName, int space) async {
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: " ",
        align: SunmiPrintAlign.LEFT,
        width: space,
      ),
      ColumnMaker(
        text: groupName,
        align: SunmiPrintAlign.LEFT,
        width: (_config.left + _config.right) - space,
      ),
    ]);
  }

  Future generatePriceBreakdown(TemplateOrder order) async {
    getPriceBreakdown(
      costName: 'Subtotal:',
      amount: order.providerSubTotal,
      isSubTotal: true,
      order: order,
    );
    if (order.vat > 0) {
      getPriceBreakdown(
        costName: _vatTitle(order),
        amount: order.vat,
        order: order,
      );
    }
    if (order.deliveryFee > 0) {
      getPriceBreakdown(
        costName: 'Delivery Fee:',
        amount: order.deliveryFee,
        order: order,
      );
    }
    if (order.providerAdditionalFee > 0) {
      getPriceBreakdown(
        costName: 'Additional Fee:',
        amount: order.providerAdditionalFee,
        order: order,
      );
    }
    if (order.restaurantServiceFee > 0) {
      getPriceBreakdown(
        costName: 'Restaurant Service Fee:',
        amount: order.restaurantServiceFee,
        order: order,
      );
    }
    // if paidByCustomer is true then show service fee and processing fee else not show
    if (order.serviceFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.serviceFee > 0) {
      getPriceBreakdown(
        costName: 'Service Fee:',
        amount: order.serviceFee,
        order: order,
      );
    }
    if (order.gatewayFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.gatewayFee > 0) {
      getPriceBreakdown(
        costName: 'Processing Fee:',
        amount: order.gatewayFee,
        order: order,
      );
    }
    if (order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.paidByCustomer && order.mergeFee > 0) {
      getPriceBreakdown(
        costName: '${order.mergeFeeTitle}:',
        amount: order.mergeFee,
        order: order,
      );
    }
    if (order.customFee > 0) {
      getPriceBreakdown(
        costName: '${order.customFeeTitle}:',
        amount: order.customFee,
        order: order,
      );
    }
    if (order.discount > 0) {
      getPriceBreakdown(
        costName: 'Discount:',
        amount: order.discount,
        isDiscount: true,
        order: order,
      );
    }
    if (order.rewardDiscount > 0) {
      getPriceBreakdown(
        costName: 'Reward:',
        amount: order.rewardDiscount,
        isDiscount: true,
        order: order,
      );
    }
    if (order.roundOffAmount != 0 && order.isManualOrder) {
      getPriceBreakdown(
        costName: 'Rounding Off:',
        amount: order.roundOffAmount,
        order: order,
        isRoundOff: true,
      );
    }
    getPriceBreakdown(costName: 'Total:', amount: order.providerGrandTotal, isTotal: true, order: order);
  }

  Future getPriceBreakdown({
    required TemplateOrder order,
    required String costName,
    required num amount,
    bool isDiscount = false,
    bool isSubTotal = false,
    bool isTotal = false,
    bool isRoundOff = false,
  }) async {
    if (isTotal) {
      await SunmiPrinter.bold();
    }
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: costName,
        align: SunmiPrintAlign.LEFT,
        width: _config.left,
      ),
      ColumnMaker(
        text: isRoundOff ? '${order.currencySymbol} ${amount.isNegative ? '' : '+'}${amount / 100}' : '${isDiscount ? '-' : ''}${PriceCalculator.convertPrice(order, amount)}',
        align: SunmiPrintAlign.RIGHT,
        width: _config.right,
      )
    ]);
    if (isTotal) {
      await SunmiPrinter.resetBold();
    }
  }

  Future generateInternalID(TemplateOrder order) async {
    await SunmiPrinter.bold();
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "INTERNAL ID",
        align: SunmiPrintAlign.LEFT,
        width: _config.left,
      ),
      ColumnMaker(
        text: '#${order.id}',
        align: SunmiPrintAlign.RIGHT,
        width: _config.right,
      )
    ]);
    await SunmiPrinter.resetBold();
  }

  Future generateQrInfo(QrInfo qrInfo) async {
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText(qrInfo.qrLabel);

    await SunmiPrinter.lineWrap(1);
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printQRCode(qrInfo.qrContent);
  }

  Future generateFooter() async {
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Powered By');

    Uint8List byte = await _getImageFromAsset('packages/docket_design_template/assets/images/app_logo.jpg');
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printImage(byte);

    await SunmiPrinter.lineWrap(1);

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Klikit');
    await SunmiPrinter.lineWrap(2);
  }

  Future printOrderComment(String comment) async {
    await SunmiPrinter.bold();
    await SunmiPrinter.printText("Note: $comment");
    await SunmiPrinter.resetBold();
  }

  Future generateThreePlInfo(TemplateOrder order) async {
    if (order.fulfillmentExpectedPickupTime.isNotEmpty) {
      await SunmiPrinter.printText(
        'PickUp Time: ${DateTimeProvider.pickupTime(order.fulfillmentExpectedPickupTime)}',
      );
    }

    if (order.fulfillmentRider != null && order.fulfillmentRider?.name != null) {
      await SunmiPrinter.printText(
        'Driver Name: ${order.fulfillmentRider!.name}',
      );
    }

    if (order.fulfillmentRider != null && order.fulfillmentRider?.phone != null) {
      await SunmiPrinter.printText(
        'Driver Phone: ${order.fulfillmentRider!.phone}',
      );
    }

    if (order.fulfillmentRider != null && order.fulfillmentRider?.phone != null) {
      await SunmiPrinter.printText(
        'License Plate: ${order.fulfillmentRider!.licensePlate}',
      );
    }

    await SunmiPrinter.printText(
      'PickUp Time: ${DateTimeProvider.pickupTime(order.fulfillmentExpectedPickupTime)}',
    );
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
      return 'Vat';
    }
    return 'Inc. Vat';
  }
}
