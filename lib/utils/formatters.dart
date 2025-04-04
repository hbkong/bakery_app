import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat('#,###');

  static String formatCurrency(int price) {
    if (price == 0) {
      return '무료';
    }
    return '${_currencyFormat.format(price)}원';
  }
}
