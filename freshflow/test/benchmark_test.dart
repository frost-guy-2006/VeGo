// Ignore: avoid_print
import 'package:vego/core/models/product_model.dart';

void main() {
  final stopwatch = Stopwatch()..start();

  // We cannot easily benchmark network requests against a mock DB, but we can benchmark
  // the client side filtering versus regex.
  // ...
  print('Benchmark complete.');
}
