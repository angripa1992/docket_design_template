import 'package:intl/intl.dart';

import '../model/order.dart';

class PriceUtil{

  static num convertCentAmount(num priceInCent){
    return priceInCent/100;
  }
  static String formatPrice({
    required num price,
    required String currencySymbol,
    required String name,
  }) {
    if(price == 0) {
      return "";
    }
    if (name.toUpperCase() == 'IDR') {
      return NumberFormat.currency(locale: 'ID', symbol: currencySymbol,decimalDigits: 0).format(price);
    } else if (name.toUpperCase() == 'JPY') {
      return NumberFormat.currency(locale: 'ja', symbol: currencySymbol, decimalDigits: 0).format(price);
    } else if (name.toUpperCase() == "PHP") {
      return NumberFormat.currency(name: name, symbol: 'P', decimalDigits: 2).format(price);
    }
    return NumberFormat.currency(name: name, symbol: currencySymbol, decimalDigits: 2).format(price);
  }
  static num parseStringToNum(String st){

    var data = st.split(".");
    num n = num.parse(data[0].replaceAll("/[^0-9]/", ""));

    return n;
  }
}