import '../model/font_size.dart';

enum Roll {
  mm58,
  mm80,
}
enum PaperLength {
  m2_202_mm58_half_left(18),
  mm80_half_left(28),
  max_mm58(32),
  max_mm80(48);
  const PaperLength(this.value);
  final int value;

  static PaperLength getByValue(int i){
    return PaperLength.values.firstWhere((x) => x.value == i);
  }
}
enum Docket {
  kitchen,
  customer,
}

enum PrintingType {
  auto,
  manual,
}

class PrinterConfiguration {
  final Docket docket;
  final Roll roll;
  final PrinterFonts fontSize;
  final PrintingType printingType;

  PrinterConfiguration({
    required this.docket,
    required this.roll,
    required this.fontSize,
    required this.printingType,
  });
}

class SunmiSizeConfig {
  final int left;
  final int right;
  final int tripleColumnLeft;
  final int tripleColumnRight;
  final int tripleColumnCenter;

  SunmiSizeConfig({
    required this.left,
    required this.right,
    required this.tripleColumnLeft,
    required this.tripleColumnRight,
    required this.tripleColumnCenter,
  });
}

SunmiSizeConfig sunmiSizeConfig(Roll roll) {
  if (roll == Roll.mm58) {
    return SunmiSizeConfig(
      left: 15,
      right: 15,
      tripleColumnLeft: 12,
      tripleColumnCenter: 6,
      tripleColumnRight: 12,
    );
  }
  return SunmiSizeConfig(
    left: 22,
    right: 22,
    tripleColumnLeft: 18,
    tripleColumnCenter: 8,
    tripleColumnRight: 18,
  );
}
