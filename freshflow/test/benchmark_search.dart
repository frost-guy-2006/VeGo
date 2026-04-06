import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Benchmark: Search Filtering String matches vs RegExp', () {
    final start = DateTime.now();
    int matchCount = 0;
    for (int i = 0; i < 10000; i++) {
      final name =
          'Product $i ${i % 2 == 0 ? "Tomato" : "Apple"} ${i % 5 == 0 ? "Red" : "Green"}';
      if (name.toLowerCase().contains('tomato')) {
        matchCount++;
      }
    }
    final duration = DateTime.now().difference(start);
    print('String matches duration: ${duration.inMicroseconds} microseconds');

    final start2 = DateTime.now();
    int matchCount2 = 0;
    final regex = RegExp('tomato', caseSensitive: false);
    for (int i = 0; i < 10000; i++) {
      final name =
          'Product $i ${i % 2 == 0 ? "Tomato" : "Apple"} ${i % 5 == 0 ? "Red" : "Green"}';
      if (regex.hasMatch(name)) {
        matchCount2++;
      }
    }
    final duration2 = DateTime.now().difference(start2);
    print('RegExp matches duration: ${duration2.inMicroseconds} microseconds');
  });
}
