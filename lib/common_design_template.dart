import 'dart:collection';
import 'dart:typed_data';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:image/image.dart' as im;
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
import 'package:docket_design_template/utils/price_utils.dart';
import 'package:docket_design_template/utils/printer_configuration.dart';
import 'package:docket_design_template/utils/printer_helper.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CommonDesignTemplate {
  static final _instance = CommonDesignTemplate._internal();

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

  Future<List<int>>? generateTicket({
    required TemplateOrder order,
    required bool isConsumerCopy,
    required Roll roll,
    required PrintingType printingType,
    required Locale locale,
  }) async {
    Translator.setLocale(locale);
    final profile = await CapabilityProfile.load();
    final generator = Generator(roll == Roll.mm58 ? PaperSize.mm58 : PaperSize.mm80, profile);

    List<int> bytes = [];

    bytes += PrinterHelper.rowBytes(generator: generator, roll: roll, data: '${StringKeys.order_date.tr()}: ${DateTimeProvider.orderCreatedDate(order.createdAt)} at ${DateTimeProvider.orderCreatedTime(order.createdAt)}');

    if (!isConsumerCopy && order.queueNo.isNotEmpty) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${StringKeys.queue_no.tr()}:', str2: order.queueNo);
    }
    if (order.klikitComment.isNotEmpty) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${StringKeys.note.tr()}:', str2: order.klikitComment);
    }

    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: order.placedOn, str2: (order.providerId == ProviderID.KLIKIT) ? '#${order.id}' : '#${order.shortId}',posStyles: const PosStyles(bold: true));

    if (order.status == OrderStatus.PLACED || order.status == OrderStatus.ACCEPTED || order.status == OrderStatus.READY) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${StringKeys.customer_name.tr()}:', str2: '${order.userFirstName} ${order.userLastName}');
    }
    if (order.tableNo.isNotEmpty) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${StringKeys.table_no.tr()}:', str2: '#${order.tableNo}');
    }
    if (order.deliveryTime.isNotEmpty) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${StringKeys.delivery_time.tr()}:', str2: order.deliveryTime);
    }
    if (order.isMerchantDelivery && order.deliveryAddress.isNotEmpty) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${StringKeys.delivery_address.tr()}:', str2: order.deliveryAddress);
    }
    if (order.providerId == ProviderID.KLIKIT) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${StringKeys.payment_status.tr()}:', str2: OrderInfoProvider().paymentStatus(order.paymentStatus));
    }
    if ((order.providerId == ProviderID.KLIKIT && order.paymentStatus == PaymentStatus.paid) || (order.providerId == ProviderID.UBER_EATS && order.paymentMethod > 0)) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${StringKeys.payment_method.tr()}:', str2: OrderInfoProvider().paymentMethod(order.paymentMethod),posStyles: const PosStyles(bold: true));
    }
    bytes += PrinterHelper.rowBytes(data: '${StringKeys.long_id.tr()}: #${order.externalId}', generator: generator, posStyles: const PosStyles.defaults(), roll: roll);
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    if(order.branchName.isNotEmpty) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${StringKeys.branch_name.tr()}: ', str2: order.branchName,posStyles: const PosStyles.defaults(bold: true));
      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    }

    if (isConsumerCopy) {
      bytes += PrinterHelper.rowBytes(data: StringKeys.note_to_customer.tr(), generator: generator,posStyles: const PosStyles(bold: true), roll: roll);
    }
    if (printingType == PrintingType.manual) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${StringKeys.order_status.tr()}:', str2: OrderInfoProvider().orderStatus(order.status));
    }
    if (order.pickupAt.isNotEmpty) {
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${StringKeys.estimated_pickup_time.tr()}:', str2: order.pickupAt);
    }

    if (order.orderComment.isNotEmpty) {
      bytes += PrinterHelper.rowBytes(data: '${StringKeys.note.tr()}: ${order.orderComment}', generator: generator, posStyles: const PosStyles.defaults(), roll: roll);
    }

    // var totalItems = order.brands.length;
    Map<String, List<TemplateCart>>? orders = await _generateCart(order.brands, order.cartV2);
    // for (var i = 0; i < totalItems; i++) {

    orders?.forEach((brand, carts) {
      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
      bytes += PrinterHelper.rowBytes(generator: generator, roll: roll, data: brand,posStyles: const PosStyles.defaults(bold: true));
      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
      bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${carts.length} ${StringKeys.item.tr().toLowerCase()}${carts.length > 1 ? '(s)' : ''}', str2: _orderType(order));
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
            bytes += PrinterHelper.rowBytes(generator: generator, roll: roll, data: '  ${el.name}', posStyles: const PosStyles.defaults());
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
          str1: '${StringKeys.subtotal.tr()}:',
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
            str1: '${StringKeys.delivery_fee.tr()}:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.deliveryFee)));
      }
      if (order.providerAdditionalFee > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: '${StringKeys.additional_fee.tr()}:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.additionalFee)));
      }
      if (order.restaurantServiceFee > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: '${StringKeys.restaurant_service_fee.tr()}:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.restaurantServiceFee)));
      }
      if (order.serviceFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.serviceFee > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: '${StringKeys.service_fee.tr()}:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.serviceFee)));
      }
      if (order.gatewayFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.gatewayFee > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: '${StringKeys.processing_fee.tr()}:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.gatewayFee)));
      }
      if (order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.paidByCustomer && order.mergeFee > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: '${StringKeys.processing_fee.tr()}:',
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
            str1: '${StringKeys.discount.tr()}:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.customerDiscount)));
      }
      if (order.rewardDiscount > 0) {
        bytes += PrinterHelper.columnBytes(
            generator: generator,
            roll: roll,
            str1: '${StringKeys.reward.tr()}:',
            str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.rewardDiscount)));
      }
      if (order.roundOffAmount != 0 || order.providerRoundOffAmount != 0) {
        final amount = order.isManualOrder ? order.roundOffAmount : order.providerRoundOffAmount;
        bytes += PrinterHelper.columnBytes(
          generator: generator,
          roll: roll,
          str1: '${StringKeys.reward.tr()}:',
          str2: '${order.currencySymbol} ${amount.isNegative ? '' : '+'}${amount / 100}',
        );
      }

      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
      bytes += PrinterHelper.columnBytes(
          generator: generator,
          roll: roll,
          str1: '${StringKeys.total.tr()}:',
          str2: PriceUtil.formatPrice(name: order.currency, currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.providerGrandTotal)),posStyles: const PosStyles(bold: true));
      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    }
    bytes += PrinterHelper.columnBytes(generator: generator, roll: roll, str1: '${StringKeys.internal_id.tr().toUpperCase()}:', str2: '#${order.id}');
    bytes += generator.text(PrinterHelper.getLine(roll));
    //footer
    bytes += generator.text(StringKeys.powered_by.tr(), styles: const PosStyles(align: PosAlign.center));

    Uint8List imageBytesFromAsset = await readFileBytes("packages/docket_design_template/assets/images/app_logo.jpg");
    final decodedImage = im.decodeImage(imageBytesFromAsset);

    bytes += generator.imageRaster(decodedImage!, align: PosAlign.center);

    bytes += generator.text('klikit', styles: const PosStyles(bold:false,align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  String _vatTitle(order) {
    if (order.providerId == ProviderID.FOOD_PANDA && !order.isInterceptorOrder && !order.isVatIncluded) {
      return StringKeys.vat.tr();
    }
    return StringKeys.inc_vat.tr();
  }

  String _orderType(order) {
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
}
