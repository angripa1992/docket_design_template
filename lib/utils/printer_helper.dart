import 'package:docket_design_template/utils/printer_configuration.dart';

class PrinterHelper{
  // Function to split the text into multiple lines
  static const String spaceList = '                                                           ';
  static const String lines = '--------------------------------------------------------';

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
    lines.add(text);
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
}