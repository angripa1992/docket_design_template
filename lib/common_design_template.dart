import 'dart:collection';
import 'dart:typed_data';


import 'package:docket_design_template/model/brand.dart';
import 'package:docket_design_template/model/cart.dart';
import 'package:docket_design_template/model/order.dart';
import 'package:docket_design_template/utils/constants.dart' as ddConsts;
import 'package:docket_design_template/utils/constants.dart';
import 'package:docket_design_template/utils/order_info_provider.dart';
import 'package:docket_design_template/utils/price_utils.dart';
import 'package:docket_design_template/utils/printer_configuration.dart';
import 'package:docket_design_template/utils/printer_helper.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;

class CommonDesignTemplate {
  static final _instance = CommonDesignTemplate._internal();
  static const int _modifierPadding = 2;
  factory CommonDesignTemplate() => _instance;

  CommonDesignTemplate._internal();

  Future<List<int>>? generateSample({required Roll roll, required int id}) async{
    final profile = await CapabilityProfile.load();
    final generator = Generator(
        roll == Roll.mm58 ? PaperSize.mm58 : PaperSize.mm80, profile);

    List<int> bytes = [];

    bytes += generator.text("background printing for incoming order id : $id", styles: const PosStyles(align: PosAlign.left));
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }


  Future<Map<String, List<TemplateCart>>?> _generateCart(List<TemplateCartBrand> brands, List<TemplateCart> cartV2) async{
    Map<String, List<TemplateCart>> map = HashMap();
    for(TemplateCartBrand t in brands){
      map.putIfAbsent(t.title, () => <TemplateCart>[]);
    }
    for(TemplateCart c in cartV2){
      map[c.cartBrand.title]?.add(c);
    }
    return map;
  }

  Future<List<int>>? generateTicket({required TemplateOrder order, required bool isConsumerCopy, required Roll roll, required PrintingType printingType}) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(
        roll == Roll.mm58 ? PaperSize.mm58 : PaperSize.mm80, profile);

    List<int> bytes = [];

    bytes += generator.text("Order Date: ${order.createdAt}", styles: const PosStyles(align: PosAlign.left));

    if (!isConsumerCopy && order.queueNo.isNotEmpty) {
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,"Queue No:","${order.queueNo}"), styles: const PosStyles(bold: true));
    }
    if(order.klikitComment.isNotEmpty) {
      bytes += generator.text('Note: ${order.klikitComment}', styles: const PosStyles(align: PosAlign.left));
    }

    bytes += generator.text(PrinterHelper.parseLeftRight(roll,order.placedOn, (order.providerId == ddConsts.ProviderID.KLIKIT) ? '#${order.id}' : '#${order.shortId}'),styles: const PosStyles(align: PosAlign.left,bold: true));

    if (order.status == ddConsts.OrderStatus.PLACED ||
        order.status == ddConsts.OrderStatus.ACCEPTED ||
        order.status == ddConsts.OrderStatus.READY) {
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Customer Name:', '${order.userFirstName} ${order.userLastName}'), styles: const PosStyles(bold: true,align: PosAlign.left));
    }
    if (order.tableNo.isNotEmpty) {
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Table No:', '#${order.tableNo}'), styles: const PosStyles(align: PosAlign.left));
    }
    if (order.providerId == ddConsts.ProviderID.KLIKIT) {
      var separator = " | ";
      var paymentDisplay = OrderInfoProvider().paymentStatus(order.paymentStatus);
      if (order.paymentStatus == ddConsts.PaymentStatus.paid) {
        paymentDisplay += separator;
        paymentDisplay += OrderInfoProvider().paymentMethod(order.paymentMethod);
      }
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,paymentDisplay,''), styles: const PosStyles(align:PosAlign.left));
    }
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Long ID: ','#${order.externalId}'), styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Branch Name: ',order.branchName), styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());


    if (isConsumerCopy) {
      bytes += generator.text(ddConsts.Consts.customerNote, styles: const PosStyles.defaults());
    }
    if (printingType == PrintingType.manual) {
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Order Status:', OrderInfoProvider().orderStatus(order.status)), styles: const PosStyles(align: PosAlign.left));
    }
    if (order.pickupAt.isNotEmpty) {
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Estimated Pickup Time:', order.pickupAt), styles: const PosStyles(align: PosAlign.left));
    }

    if (order.orderComment.isNotEmpty) {
      bytes += generator.text('Note: ${order.orderComment}', styles: const PosStyles.defaults());
    }

    // var totalItems = order.brands.length;
    Map<String, List<TemplateCart>>? orders = await _generateCart(order.brands,order.cartV2);
    // for (var i = 0; i < totalItems; i++) {

    orders?.forEach((brand, carts) {
      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,brand, ''), styles: const PosStyles(bold: true));
      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());

      bytes += generator.text(PrinterHelper.parseLeftRight(roll, '${carts.length} item${carts.length > 1 ? '(s)' : ''}', _orderType(order)), styles: const PosStyles.defaults());
      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
      for (var element in carts) {
        var names = PrinterHelper.splitTextToFitRow(text: '${element.quantity}x ${element.name}', roll: roll,fillRow: isConsumerCopy);
        var itemPrice =  num.parse(element.unitPrice) * element.quantity;
        if(isConsumerCopy) {
          bytes += generator.text(PrinterHelper.parseLeftRight(roll,names[0], PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price:itemPrice)),styles: const PosStyles(align: PosAlign.left,bold: true));
        } else {
          bytes += generator.text(PrinterHelper.parseLeftRight(roll,names[0], ''),styles: const PosStyles(align: PosAlign.left,bold: true));
        }
        int totalPadding = element.quantity.toString().length+ _modifierPadding;
        for (int i=1;i<names.length;i++) {
          bytes += generator.text(PrinterHelper.parseLeftRight(roll,PrinterHelper.getSpaces(totalPadding)+names[i],''),styles: const PosStyles(align: PosAlign.left,bold: true));
        }
        if (element.modifierGroups.isNotEmpty) {
          for (var el in element.modifierGroups) {
            bytes += generator.text(PrinterHelper.parseLeftRight(roll,'${PrinterHelper.getSpaces(totalPadding)}${el.name}', ''),styles: const PosStyles(align: PosAlign.left));

            for (var el2 in el.modifiers) {
              bool fillRow = num.parse(el2.price)==0;
              var names = PrinterHelper.splitTextToFitRow(text: '${PrinterHelper.getSpaces(totalPadding)}${el2.quantity}x ${el2.name}', roll: roll,fillRow: !fillRow);
              if(isConsumerCopy) {
                bytes += generator.text(PrinterHelper.parseLeftRight(roll,names[0], fillRow?'':PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price:num.parse(el2.unitPrice) * el2.quantity)),styles: const PosStyles(align: PosAlign.left));
              }else{
                bytes += generator.text(PrinterHelper.parseLeftRight(roll,names[0], ''),styles: const PosStyles(align: PosAlign.left));
              }
              for (int i=1;i<names.length;i++) {
                bytes += generator.text(PrinterHelper.parseLeftRight(roll,PrinterHelper.getSpaces(totalPadding) + names[i],'',), styles: const PosStyles(align: PosAlign.left));
              }
            }
          }
        }
        // }
      }
    });


    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    if(isConsumerCopy){
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Subtotal: ', PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price:PriceUtil.convertCentAmount(order.providerSubTotal))),styles: const PosStyles(align: PosAlign.left));
      if(order.vat>0) {
        bytes += generator.text(PrinterHelper.parseLeftRight(roll,_vatTitle(order), PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price:PriceUtil.convertCentAmount(order.vat))),styles: const PosStyles(align: PosAlign.left));
      }
      if(order.deliveryFee>0) {
        bytes += generator.text(PrinterHelper.parseLeftRight(roll,'Delivery Fee: ', PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.deliveryFee))),styles: const PosStyles(align: PosAlign.left));
      }
      if(order.providerAdditionalFee>0) {
        bytes += generator.text(PrinterHelper.parseLeftRight(roll,"Additional Fee: ", PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.providerAdditionalFee))),styles: const PosStyles(align: PosAlign.left));
      }
      if(order.restaurantServiceFee>0) {
        bytes += generator.text(PrinterHelper.parseLeftRight(roll,"Restaurant Service Fee: ", PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.restaurantServiceFee))),styles: const PosStyles(align: PosAlign.left));
      }
      if(order.serviceFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.serviceFee > 0) {
        bytes += generator.text(PrinterHelper.parseLeftRight(roll,"Service Fee: ", PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.serviceFee))),styles: const PosStyles(align: PosAlign.left));
      }
      if(order.gatewayFeePaidByCustomer && !order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.gatewayFee > 0) {
        bytes += generator.text(PrinterHelper.parseLeftRight(roll,"Processing Fee: ", PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.gatewayFee))),styles: const PosStyles(align: PosAlign.left));
      }
      if(order.mergeFeeEnabled && order.providerId == ProviderID.KLIKIT && order.paidByCustomer && order.mergeFee > 0) {
        bytes += generator.text(PrinterHelper.parseLeftRight(roll,"${order.mergeFeeTitle}: ", PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.mergeFee))),styles: const PosStyles(align: PosAlign.left));
      }
      if(order.customFee>0) {
        bytes += generator.text(PrinterHelper.parseLeftRight(roll,"${order.customFeeTitle}: ", PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.customFee))),styles: const PosStyles(align: PosAlign.left));
      }
      if(order.discount>0) {
        bytes += generator.text(PrinterHelper.parseLeftRight(roll,"Discount: ", PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.discount))),styles: const PosStyles(align: PosAlign.left));
      }
      if(order.rewardDiscount>0) {
        bytes += generator.text(PrinterHelper.parseLeftRight(roll,"Reward: ", PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.rewardDiscount))),styles: const PosStyles(align: PosAlign.left));
      }
      if(order.roundOffAmount != 0 && order.isManualOrder) {
        bytes += generator.text(PrinterHelper.parseLeftRight(roll,"Rounding Off: ", PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.roundOffAmount))),styles: const PosStyles(align: PosAlign.left));
      }

      bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
      bytes += generator.text(PrinterHelper.parseLeftRight(roll,"Total: ", PriceUtil.formatPrice(name:order.currency,currencySymbol: order.currencySymbol, price: PriceUtil.convertCentAmount(order.providerGrandTotal))),styles: const PosStyles(align: PosAlign.left,bold: true));
    }
    bytes += generator.text(PrinterHelper.parseLeftRight(roll,"INTERNAL ID: ", '#${order.id}'),styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(PrinterHelper.getLine(roll), styles: const PosStyles.defaults());
    //footer
    bytes += generator.text('Powered by',styles: const PosStyles(align: PosAlign.center));

    // Uint8List imageBytesFromAsset = await readFileBytes("packages/docket_design_template/assets/images/app_logo.jpg");
    // final decodedImage = im.decodeImage(imageBytesFromAsset);
    //
    // bytes += generator.image(decodedImage!);

    bytes += generator.text('klikit',styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  String _vatTitle(order) {
    if (order.providerId == ddConsts.ProviderID.FOOD_PANDA &&
        !order.isInterceptorOrder &&
        !order.isVatIncluded) {
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
