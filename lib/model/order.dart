import 'package:docket_design_template/model/brand.dart';
import 'package:docket_design_template/model/cart.dart';
import 'package:docket_design_template/model/rider_info.dart';

class TemplateOrder {
  final int id;
  final String branchName;
  final String externalId;
  final String shortId;
  final int status;
  final int paymentStatus;
  final int paymentMethod;
  final int providerId;
  final int itemPrice;
  final int finalPrice;
  final int discount;
 // final int customerDiscount;
  final int deliveryFee;
  final int additionalFee;
  final int gatewayFee;
  final int serviceFee;
  final int restaurantServiceFee;
  final int vat;
  final String currencySymbol;
  final String currency;
  final String createdAt;
  final int itemCount;
  final String userFirstName;
  final String userLastName;
  final List<TemplateCartBrand> brands;
  final List<TemplateCart> cartV2;
  final bool isInterceptorOrder;
  final String orderComment;
  final String klikitComment;
  final int type;
  final String placedOn;
  final String tableNo;
  final bool isManualOrder;
  final bool isFoodpandaApiOrder;
  final bool isVatIncluded;
  final QrInfo? qrInfo;
  final bool isThreePlOrder;
  final String fulfillmentDeliveredTime;
  final String fulfillmentExpectedPickupTime;
  final String fulfillmentPickupPin;
  final RiderInfo? fulfillmentRider;
  final int fulfillmentStatusId;
  final String fulfillmentTrackingUrl;
  final String pickupAt;
  final num providerSubTotal;
  final num providerGrandTotal;
  final num providerAdditionalFee;
  final String queueNo;
  final bool paidByCustomer;
  final String customFeeTitle;
  final num rewardDiscount;
  final num customFee;
  final num mergeFee;
  final num roundOffAmount;
  final String mergeFeeTitle;
  final bool mergeFeeEnabled;
  final bool gatewayFeePaidByCustomer;
  final bool serviceFeePaidByCustomer;

  TemplateOrder({
    required this.id,
    required this.branchName,
    required this.externalId,
    required this.shortId,
    required this.providerId,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.itemPrice,
    required this.finalPrice,
    required this.discount,
  //  required this.customerDiscount,
    required this.deliveryFee,
    required this.additionalFee,
    required this.gatewayFee,
    required this.serviceFee,
    required this.restaurantServiceFee,
    required this.vat,
    required this.currency,
    required this.currencySymbol,
    required this.itemCount,
    required this.createdAt,
    required this.userFirstName,
    required this.userLastName,
    required this.brands,
    required this.cartV2,
    required this.isInterceptorOrder,
    required this.orderComment,
    required this.klikitComment,
    required this.type,
    required this.placedOn,
    required this.qrInfo,
    required this.tableNo,
    required this.isManualOrder,
    required this.isFoodpandaApiOrder,
    required this.isVatIncluded,
    required this.isThreePlOrder,
    required this.fulfillmentDeliveredTime,
    required this.fulfillmentExpectedPickupTime,
    required this.fulfillmentPickupPin,
    required this.fulfillmentRider,
    required this.fulfillmentStatusId,
    required this.fulfillmentTrackingUrl,
    required this.pickupAt,
    required this.providerSubTotal,
    required this.providerAdditionalFee,
    required this.providerGrandTotal,
    required this.queueNo,
    required this.paidByCustomer,
    required this.customFeeTitle,
    required this.rewardDiscount,
    required this.customFee,
    required this.mergeFeeEnabled,
    required this.mergeFeeTitle,
    required this.mergeFee,
    required this.roundOffAmount,
    required this.gatewayFeePaidByCustomer,
    required this.serviceFeePaidByCustomer,
  });
}
