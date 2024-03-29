const String EMPTY = '';
const int ZERO = 0;
const double ZERO_DECIMAL = 0.0;
const bool FALSE = false;

extension NonNullString on String {
  String orEmpty() {
    if (this == null) {
      return EMPTY;
    } else {
      return this;
    }
  }
  String replacePhp() {
    return contains("₱") ? replaceAll('₱', 'P') : this;
  }
}

extension NonNullInteger on int {
  int orZero() {
    if (this == null) {
      return ZERO;
    } else {
      return this;
    }
  }
}

extension NonNullDouble on double {
  double orZero() {
    if (this == null) {
      return ZERO_DECIMAL;
    } else {
      return this;
    }
  }
}

extension NonNullBoolean on bool {
  bool orFalse(){
    return this ?? FALSE;
  }
}