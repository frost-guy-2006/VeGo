import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Search client vs server filtering benchmark mock', () async {
    // Generate mock dataset
    final int datasetSize = 10000;
    final List<Map<String, dynamic>> mockDb = List.generate(datasetSize, (i) {
      final isRed = i % 10 == 0;
      return {
        'id': i.toString(),
        'name': isRed ? 'Red Apple $i' : 'Green Apple $i',
        'image_url': '',
        'current_price': 1.0,
        'market_price': 1.5,
        'harvest_time': 'Today',
        'stock': 100,
        'category': 'Fruit',
      };
    });

    // ignore: avoid_print
    print('Benchmarking with $datasetSize mock DB items...');

    // Old approach: Fetch all + parse all + client side filter
    final swOld = Stopwatch()..start();

    // Simulate DB fetch (copying list)
    final fetchedData = List<Map<String, dynamic>>.from(mockDb);

    // In old code, fromJson takes some time and then we filter
    // We'll just simulate parsing strings
    int redCountOld = 0;
    for (var item in fetchedData) {
      final name = item['name'] as String;
      if (name.toLowerCase().contains('red')) {
        redCountOld++;
      }
    }
    swOld.stop();
    // ignore: avoid_print
    print(
        'Old Approach (Fetch all & Client Filter): ${swOld.elapsedMicroseconds} microseconds. Found: $redCountOld');

    // New approach: DB level filter (simulated) + parse subset
    final swNew = Stopwatch()..start();
    // Simulate DB filtering
    final filteredData = mockDb
        .where((item) => (item['name'] as String).toLowerCase().contains('red'))
        .toList();
    int redCountNew = filteredData.length;
    swNew.stop();
    // ignore: avoid_print
    print(
        'New Approach (Server Filter & Fetch Subset): ${swNew.elapsedMicroseconds} microseconds. Found: $redCountNew');

    final improvement =
        (swOld.elapsedMicroseconds - swNew.elapsedMicroseconds) /
            swOld.elapsedMicroseconds *
            100;
    // ignore: avoid_print
    print('Improvement: ${improvement.toStringAsFixed(2)}%');
  });
}
