import 'package:docket_design_template/translator.dart';

extension TranslationFromKey on String {
  String tr() {
    return Translator.translate(this);
  }
}
