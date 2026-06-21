class Formatters {
  Formatters._();

  static String money(num value) => '\$${value.toStringAsFixed(2)}';
}
