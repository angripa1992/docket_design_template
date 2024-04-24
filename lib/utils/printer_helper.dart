import 'package:docket_design_template/extensions.dart';
import 'package:docket_design_template/string_keys.dart';
import 'package:docket_design_template/utils/price_utils.dart';
import 'package:docket_design_template/utils/printer_configuration.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class PrinterHelper{
  // Function to split the text into multiple lines
  static const String spaceList = '                                                           ';
  static const String lines = '--------------------------------------------------------';
  static const PosStyles posStylesDefault = PosStyles(bold:true);
  static String getSpaces(int n){
      return ' '* (n-1);
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
  static List<int> rowBytes({required Generator generator,required Roll roll, required String data,  PosStyles? posStyles}){
    List<int> bytes = [];
    PosStyles aPosStyle = const PosStyles(align: PosAlign.left);
    if(posStyles != null){
      aPosStyle = posStyles;
    }
    List<String> printData = splitText(text: data,roll: roll);
    for (var st in printData) {
      bytes += generator.text(st, styles:  aPosStyle);
    }

    return bytes;
  }
  static List<int> columnBytes({required Generator generator,required Roll roll, required String str1, required String str2, PosStyles? posStyles}){

    List<int> bytes = [];
    PosStyles aPosStyle = const PosStyles(align: PosAlign.left);
    if (posStyles != null) {
      aPosStyle = posStyles;
    }
    int maxPerColumn = (roll == Roll.mm58 ? PaperLength.max_mm58.value ~/ 2 : PaperLength.max_mm80.value ~/ 2);
    num totalRows = ((str1.length + maxPerColumn - 1) ~/ maxPerColumn).clamp(1, double.infinity);
    int currPosition = 0;

    for (int i = 0; i < totalRows; i++) {
      String s1 = "";
      String s2 = "";

      if (currPosition < str1.length) {
        s1 += str1.substring(currPosition, currPosition + maxPerColumn > str1.length ? str1.length : currPosition + maxPerColumn);
        s1 += getSpaces(maxPerColumn - s1.length);
      }
      if (currPosition < str2.length) {
        String str = str2.substring(currPosition, currPosition + maxPerColumn > str2.length ? str2.length : currPosition + maxPerColumn);
        s2 += getSpaces(maxPerColumn - str.length);
        s2 += str;
      }
      currPosition += maxPerColumn;
      bytes += generator.text('$s1$s2', styles: aPosStyle);
    }
    return bytes;
  }

  static List<int> itemToBytes({required Generator generator,required Roll roll,required int quantity, required String itemName,required String price,required String currency,required String currencySymbol,required bool customerCopy,  PosAlign? posAlign, String? orderNote}){
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
    if(orderNote != null && orderNote.isNotEmpty){
      bytes += PrinterHelper.rowBytes(data: '${StringKeys.note.tr()}: $orderNote', generator: generator, posStyles: const PosStyles.defaults(), roll: roll);
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
    bytes += generator.text(firstItem, styles: const PosStyles.defaults());

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
  static String removeSpecialIcon(String s){
    return s.replaceAll("✨", "");
  }
}