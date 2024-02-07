class ProviderID {
  static const int KLIKIT = 1;
  static const int GRAB_FOOD = 6;
  static const int FOOD_PANDA = 7;
  static const int GOFOOD = 9;
  static const int SHOPEE = 11;
}

class PaymentStatus {
  static const int paid = 1;
  static const int failed = 2;
  static const int pending = 3;
  static const int refunded = 4;
}

class OrderStatus {
  static const PLACED = 1;
  static const ACCEPTED = 2;
  static const CANCELLED = 3;
  static const READY = 4;
  static const DELIVERED = 5;
  static const SCHEDULED = 6;
  static const DRIVER_ASSIGNED = 7;
  static const DRIVER_ARRIVED = 8;
  static const PICKED_UP = 9;
}

class OrderType {
  static const int MANUAL = 0;
  static const int PICKUP = 1;
  static const int DELIVERY = 2;
  static const int DINE_IN = 3;
}

class FontSize {
  static const double small = 10;
  static const double regular = 11;
  static const double medium = 12;
  static const double large = 16;
  static const double extraLarge = 18;
}

class PaddingSize {
  static const double extraSmall = 0.5;
  static const double small = 1;
  static const double regular = 2;
  static const double medium = 4;
  static const double large = 8;
}

class RollPaperWidth {
  static const double mm58 = 64;
  static const double mm80 = 96;
}

class FulfillmentStatusId{
  static const ALLOCATING_RIDER = 1; //or 2
  static const FOUND_RIDER = 3;
  static const PICKING_UP = 4;
  static const IN_DELIVERY = 5;
  static const COMPLETED = 6;
  static const RETURNED = 7;
  static const CANCELED = 8; // or 9
  static const IN_RETURN = 10;
  static const DISPATCH_FAILED = 11;
}

class Consts {
  static const String customerNote = "** Note to customer: check order receipt in delivery app for final price **";
  static const sunmiFirstColumnWidth = 18;
  static const sunmiSecondColumnWidth = 12;
  static const textWidth = 18;
  static const priceWidth = 12;
}
