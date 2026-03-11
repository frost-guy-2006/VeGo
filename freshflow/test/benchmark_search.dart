import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    // Load .env explicitly
    await dotenv.load(fileName: '.env');

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  });

  test('Benchmark searchProducts vs fetchProducts with client filter',
      () async {
    final repo = ProductRepository();

    // Benchmark 1: Fetch all and filter client side
    final start1 = DateTime.now();
    try {
      final allProducts = await repo.fetchProducts();
      final filtered1 = allProducts
          .where((p) => p.name.toLowerCase().contains('to'))
          .toList();
      final end1 = DateTime.now();
      final diff1 = end1.difference(start1).inMilliseconds;
      print('Client-side filter time: ${diff1}ms, items: ${filtered1.length}');
    } catch (e) {
      print('Benchmark 1 failed: $e');
    }

    // Benchmark 2: Server side search
    final start2 = DateTime.now();
    try {
      final filtered2 = await repo.searchProducts('to');
      final end2 = DateTime.now();
      final diff2 = end2.difference(start2).inMilliseconds;
      print('Server-side search time: ${diff2}ms, items: ${filtered2.length}');
    } catch (e) {
      print('Benchmark 2 failed: $e');
    }
  });
}
