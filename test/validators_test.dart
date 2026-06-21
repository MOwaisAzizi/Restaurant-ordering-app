import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_ordering_app/utils/validators.dart';

void main() {
  group('Validators', () {
    test('accepts a valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('rejects invalid email', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('requires password length', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });
}
