import 'constants.dart';

class OrderInfoProvider {
  static final _instance = OrderInfoProvider._internal();

  factory OrderInfoProvider() => _instance;

  OrderInfoProvider._internal();

  String paymentStatus(int status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.pending:
        return 'Pending';
      default:
        return 'Refunded';
    }
  }

  String paymentMethod(int method) {
    switch (method) {
      case 1:
        return 'Card';
      case 2:
        return 'Cash';
      case 3:
        return 'PayPal';
      case 4:
        return 'GCash';
      case 6:
        return 'GoPay';
      case 7:
        return 'OVO';
      case 8:
        return 'ShopeePay';
      case 9:
        return 'QRIS';
      case 10:
        return 'GrabPay';
      case 11:
        return 'NextPay';
      case 12:
        return 'DANA';
      case 13:
        return 'LinkAja';
      case 14:
        return 'EWallet';
      case 15:
        return 'Bank Payment';
      case 16:
        return 'Custom';
      case 17:
        return 'QR Payment';
      default:
        return 'Other';
    }
  }

  String orderStatus(int status) {
    switch (status) {
      case OrderStatus.PLACED:
        return 'Placed';
      case OrderStatus.ACCEPTED:
        return 'Accepted';
      case OrderStatus.CANCELLED:
        return 'Cancelled';
      case OrderStatus.READY:
        return 'Ready';
      case OrderStatus.DELIVERED:
        return 'Delivered';
      case OrderStatus.SCHEDULED:
        return 'Scheduled';
      case OrderStatus.DRIVER_ASSIGNED:
        return 'Driver Assigned';
      case OrderStatus.DRIVER_ARRIVED:
        return 'Driver Arrived';
      case OrderStatus.PICKED_UP:
        return 'Picked-Up';
      default:
        return '';
    }
  }
}
