import 'dart:collection';
import 'dart:typed_data';

import 'package:docket_design_template/model/brand.dart';
import 'package:docket_design_template/model/cart.dart';
import 'package:docket_design_template/model/order.dart';
import 'package:docket_design_template/utils/constants.dart' as ddConsts;
import 'package:docket_design_template/utils/constants.dart';
import 'package:docket_design_template/utils/date_time_provider.dart';
import 'package:docket_design_template/utils/order_info_provider.dart';
import 'package:docket_design_template/utils/price_utils.dart';
import 'package:docket_design_template/utils/printer_configuration.dart';
import 'package:docket_design_template/utils/printer_helper.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';

class CommonDesignTemplate {
  static final _instance = CommonDesignTemplate._internal();
  static const int _modifierPadding = 2;

  factory CommonDesignTemplate() => _instance;

  CommonDesignTemplate._internal();

  Future<List<int>>? generateSample({required Roll roll, required int id}) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(roll == Roll.mm58 ? PaperSize.mm58 : PaperSize.mm80, profile);

    List<int> bytes = [];

    bytes += generator.text("background printing for incoming order id : $id", styles: const PosStyles(align: PosAlign.left));
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  Future<Map<String, List<TemplateCart>>?> _generateCart(List<TemplateCartBrand> brands, List<TemplateCart> cartV2) async {
    Map<String, List<TemplateCart>> map = HashMap();
    for (TemplateCartBrand t in brands) {
      map.putIfAbsent(t.title, () => <TemplateCart>[]);
    }
    for (TemplateCart c in cartV2) {
      map[c.cartBrand.title]?.add(c);
    }
    return map;
  }

  Future<List<int>>? generateTicket({required TemplateOrder order, required bool isConsumerCopy, required Roll roll, required PrintingType printingType}) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(roll == Roll.mm58 ? PaperSize.mm58 : PaperSize.mm80, profile);

    List<int> bytes = [];

    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Order Date:', str2: DateTimeProvider.orderCreatedTime(order.createdAt));

    if (!isConsumerCopy && order.queueNo.isNotEmpty) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Queue No:', str2: order.queueNo);
    }
    if (order.klikitComment.isNotEmpty) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Note:', str2: order.klikitComment);
    }

    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: order.placedOn, str2: (order.providerId == ddConsts.ProviderID.KLIKIT) ? '#${order.id}' : '#${order.shortId}');

    if (order.status == ddConsts.OrderStatus.PLACED || order.status == ddConsts.OrderStatus.ACCEPTED || order.status == ddConsts.OrderStatus.READY) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Customer Name:', str2: '${order.userFirstName} ${order.userLastName}');
    }
    if (order.tableNo.isNotEmpty) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Table No:', str2: '#${order.tableNo}');
    }
    if (order.providerId == ddConsts.ProviderID.KLIKIT) {
      var separator = " | ";
      var paymentDisplay = OrderInfoProvider().paymentStatus(order.paymentStatus);
      if (order.paymentStatus == ddConsts.PaymentStatus.paid) {
        paymentDisplay += separator;
        paymentDisplay += OrderInfoProvider().paymentMethod(order.paymentMethod);
      }
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: paymentDisplay, str2: '');
    }
    bytes += PrinterHelper.rowBytes(data: 'Long ID: #${order.externalId}', generator: generator, posAlign: PosAlign.left, roll: roll);
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Branch Name: ', str2: order.branchName);
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());

    if (isConsumerCopy) {
      bytes += PrinterHelper.rowBytes(data: Consts.customerNote, generator: generator, posAlign: PosAlign.left, roll: roll);
    }
    if (printingType == PrintingType.manual) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Order Status:', str2: OrderInfoProvider().orderStatus(order.status));
    }
    if (order.pickupAt.isNotEmpty) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'Estimated Pickup Time:', str2: order.pickupAt);
    }

    if (order.orderComment.isNotEmpty) {
      bytes += PrinterHelper.rowBytes(data: 'Note: ${order.orderComment}', generator: generator, posAlign: PosAlign.left, roll: roll);
    }

    // var totalItems = order.brands.length;
    Map<String, List<TemplateCart>>? orders = await _generateCart(order.brands, order.cartV2);
    // for (var i = 0; i < totalItems; i++) {

    orders?.forEach((brand, carts) {
      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
      bytes += PrinterHelper.rowBytes(generator: generator, roll: roll, data: brand);
      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${carts.length} item${carts.length > 1 ? '(s)' : ''}', str2: _orderType(order));
      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
      for (var element in carts) {
        bytes += PrinterHelper.itemToBytes(
            generator: generator,
            roll: roll,
            quantity: element.quantity,
            itemName: element.name,
            price: element.unitPrice,
            currency: order.currency,
            currencySymbol: order.currencySymbol,
            customerCopy: isConsumerCopy);
        if (element.modifierGroups.isNotEmpty) {
          for (var el in element.modifierGroups) {
            bytes += PrinterHelper.rowBytes(generator: generator, roll: roll, data: '  ${el.name}', posAlign: PosAlign.left);
            for (var modifier in el.modifiers) {
              bytes += PrinterHelper.modifierToBytes(
                  generator: generator,
                  roll: roll,
                  quantity: modifier.quantity,
                  modifierName: modifier.name,
                  price: modifier.unitPrice,
                  currency: order.currency,
                  currencySymbol: order.currencySymbol,
                  customerCopy: isConsumerCopy);
            }
          }
        }
        // }
      }
    });

    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    if (isConsumerCopy) {
      bytes += PrinterHelper.columnBytes(
          generator: generator,
          roll: roll,
          str1: 'Subtotal:',
          str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.providerSubTotal)));
      if (order.vat > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: _vatTitle(order),
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.vat)));
      }
      if (order.deliveryFee > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: 'Delivery Fee:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.deliveryFee)));
      }
      if (order.providerAdditionalFee > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: 'Additional Fee:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.additionalFee)));
      }
      if (order.restaurantServiceFee > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: 'Restaurant Service Fee:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.restaurantServiceFee)));
      }
      if (order.serviceFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.serviceFee > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: 'Service Fee:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.serviceFee)));
      }
      if (order.gatewayFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.gatewayFee > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: 'Processing Fee:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.gatewayFee)));
      }
      if (order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.paidByCustomer && order.mergeFee > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: 'Processing Fee:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.mergeFee)));
      }
      if (order.customFee > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: '${order.customFeeTitle}:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.customFee)));
      }
      if (order.customerDiscount > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: 'Discount:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.customerDiscount)));
      }
      if (order.rewardDiscount > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: 'Reward:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.rewardDiscount)));
      }
      if (order.roundOffAmount != 0 || order.providerRoundOffAmount != 0) {
        final amount = order.isManualOrder ? order.roundOffAmount : order.providerRoundOffAmount;
        bytes += PrinterHelper.columnBytes(
          generator: generator,
          roll: roll,
          str1: 'Rounding Off:',
          str2: '${order.currencySymbol} ${amount.isNegative ? '' : '+'}${amount / 100}',
        );
      }

      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
      bytes += PrinterHelper.columnBytes(
          generator: generator,
          roll: roll,
          str1: 'Total:',
          str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.providerGrandTotal)));
    }
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: 'INTERNAL ID:', str2: '#${order.id}');
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    //footer
    bytes += generator.text('Powered by', styles: const PosStyles(align: PosAlign.center));

    // Uint8List imageBytesFromAsset = await readFileBytes("packages/docket_design_template/assets/images/app_logo.jpg");
    // final decodedImage = im.decodeImage(imageBytesFromAsset);
    //
    // bytes += generator.image(decodedImage!);

    bytes += generator.text('klikit', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  String _vatTitle(order) {
    if (order.providerId == ddConsts.ProviderID.FOOD_PANDA && !order.isInterceptorOrder && !order.isVatIncluded) {
      return 'Vat';
    }
    return 'Inc. Vat';
  }

  String _orderType(order) {
    if (order.type == ddConsts.OrderType.DELIVERY) {
      return 'Delivery';
    } else if (order.type == ddConsts.OrderType.PICKUP) {
      return 'Pickup';
    } else if (order.type == ddConsts.OrderType.DINE_IN) {
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
}
