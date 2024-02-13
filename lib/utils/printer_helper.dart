import 'package:docket_design_template/utils/price_utils.dart';
import 'package:docket_design_template/utils/printer_configuration.dart';
import 'package:docket_design_template/utils/printerenum.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class PrinterHelper{
  // Function to split the text into multiple lines
  static const String spaceList = '                                                           ';
  static const String lines = '--------------------------------------------------------';
  static const PosStyles posStylesDefault = PosStyles(bold:true);
  static String getSpaces(int n){
    return spaceList.substring(0,n);
  }

  static List<String> splitTextToFitRow({required String text, required Roll roll, required bool fillRow}) {
    //2 padding
    int maxPerLine ;
    if(fillRow) {
      maxPerLine=  (roll == Roll.mm58 ? PaperLength.m2_202_mm58_half_left.value : PaperLength.mm80_half_left.value);
    }else{
      maxPerLine=  (roll == Roll.mm58 ? PaperLength.max_mm58.value : PaperLength.max_mm80.value);
    }
    List<String> lines = [];

    while (text.length > maxPerLine) {
      String cut = text.substring(0, maxPerLine);
      lines.add(cut);
      text = text.substring(maxPerLine);
    }
    lines.add(text+getSpaces(maxPerLine-text.length));
    return lines;
  }

  static List<String> splitText({required String text, required Roll roll}) {
    //2 padding
    int maxPerLine = (roll == Roll.mm58 ? PaperLength.max_mm58.value : PaperLength.max_mm80.value);

    List<String> lines = [];

    while (text.length > maxPerLine) {
      String cut = text.substring(0, maxPerLine);
      lines.add(cut);
      text = text.substring(maxPerLine);
    }
    lines.add(text+getSpaces(maxPerLine-text.length));
    return lines;
  }
  static String getLine(Roll roll) {
    int length = roll == Roll.mm58 ? PaperLength.max_mm58.value : PaperLength.max_mm80.value;
    return lines.substring(0,length);
  }
  static String parseLeftRight(Roll roll, String str1, String str2){
    int length = roll == Roll.mm58 ? PaperLength.max_mm58.value : PaperLength.max_mm80.value;
    int spaces = length - str1.length - str2.length;
    String temp = str1;
    temp += spaceList.substring(0,spaces);
    temp += str2;
    return temp;
  }
  static List<int> rowBytes({required Generator generator,required Roll roll, required String data,  PosAlign? posAlign}){
    List<int> bytes = [];
    PosStyles posStyles = const PosStyles(align: PosAlign.left,bold:false);
    List<String> printData = splitText(text: data,roll: roll);
    for (var st in printData) {
      bytes += generator.text(st, styles:  posStyles);
    }

    return bytes;
  }

  static List<int> columnBytes({required Generator generator,required Roll roll, required String str1, required String str2}){
    List<int> bytes = [];

    int length = roll == Roll.mm58 ? PaperLength.max_mm58.value : PaperLength.max_mm80.value;
    int dataLength = str1.length + str2.length + 1;
    if(dataLength <= length){
      return generator.text(str1 + getSpaces(length-dataLength) + str2, styles:  const PosStyles(align: PosAlign.left));
    }
    int str1ToCut = length - str2.length - 2;
    String firstItem = str1.substring(0,str1ToCut)+' '+str2;
    bytes += generator.text(firstItem, styles: PosStyles.defaults());
    String data = str1.substring(str1ToCut);
    List<String> printData = splitText(text: data,roll: roll);
    for (var st in printData) {
      bytes += generator.text(st, styles:  const PosStyles(align: PosAlign.left));
    }

    return bytes;
  }

  static List<int> itemToBytes({required Generator generator,required Roll roll,required int quantity, required String itemName,required String price,required String currency,required String currencySymbol,required bool customerCopy,  PosAlign? posAlign}){
    List<int> bytes = [];

    String amt = PriceUtil.formatPrice(name:currency,currencySymbol: currencySymbol, price:num.parse(price) * quantity);
    int priceLength = amt.length;
    String qty = '${quantity}x ';
    int qtyLength = qty.length;
    int length = roll == Roll.mm58 ? PaperLength.max_mm58.value : PaperLength.max_mm80.value;
    int spaceInLength = customerCopy ? length - priceLength - itemName.length - qtyLength : length - itemName.length - qtyLength;

    String firstItem;
    if(spaceInLength > 0){
      firstItem = customerCopy ? qty + itemName + getSpaces(spaceInLength) + amt : qty + itemName;
      bytes += generator.text(leftAlign(data: firstItem, rowsLength: length), styles: const PosStyles.defaults(bold: true));
      return bytes;
    }
    int totalFirstCharsPrinter = itemName.length + spaceInLength - 1;
    firstItem = customerCopy ? '$qty${itemName.substring(0, totalFirstCharsPrinter)} $amt' : '$qty${itemName.substring(0, totalFirstCharsPrinter)}';
    bytes += generator.text(firstItem, styles: const PosStyles.defaults(bold: true));

    //print next line item
    String nextStr = itemName.substring(totalFirstCharsPrinter);
    List<String> str = splitTextToFitRow(text: nextStr, roll: roll,fillRow: customerCopy);
    for (var element in str) {
      bytes += generator.text(leftAlign(data: '${getSpaces(qtyLength)}$element', rowsLength: length), styles: const PosStyles.defaults(bold: true));
    }

    return bytes;
  }

  static List<int> modifierToBytes({required Generator generator,required Roll roll,required int quantity, required String modifierName,required String price,required String currency,required String currencySymbol,required bool customerCopy,  PosAlign? posAlign}){
    List<int> bytes = [];

    String amt = PriceUtil.formatPrice(name:currency,currencySymbol: currencySymbol, price:num.parse(price) * quantity);
    int priceLength = amt.length;
    String qty = '  ${quantity}x ';
    int qtyLength = qty.length;
    int length = roll == Roll.mm58 ? PaperLength.max_mm58.value : PaperLength.max_mm80.value;
    int spaceInLength = customerCopy ? length - priceLength - modifierName.length - qtyLength : length - modifierName.length - qtyLength;

    String firstItem;
    if(spaceInLength > 0){
      firstItem = customerCopy ? qty + modifierName + getSpaces(spaceInLength) + amt : qty + modifierName;
      bytes += generator.text(leftAlign(data: firstItem, rowsLength: length), styles: const PosStyles.defaults());
      return bytes;
    }
    int totalFirstCharsPrinter = modifierName.length + spaceInLength - 1;
    firstItem = customerCopy ? '$qty${modifierName.substring(0, totalFirstCharsPrinter)} $amt' : '$qty${modifierName.substring(0, totalFirstCharsPrinter)}';
    bytes += generator.text(firstItem, styles: PosStyles.defaults());

    //print next line item
    String nextStr = modifierName.substring(totalFirstCharsPrinter);
    List<String> str = splitTextToFitRow(text: nextStr, roll: roll,fillRow: customerCopy);
    for (var element in str) {
      bytes += generator.text(leftAlign(data: '${getSpaces(qtyLength)}$element', rowsLength: length), styles: const PosStyles.defaults());
    }

    return bytes;
  }
  static String leftAlign({required String data, required int rowsLength}){
    return '$data${getSpaces(rowsLength - data.length)}';
  }

}