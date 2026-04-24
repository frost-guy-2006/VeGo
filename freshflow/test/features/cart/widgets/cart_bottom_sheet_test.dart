import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vego/features/cart/widgets/cart_bottom_sheet.dart';


void main() {
  testWidgets('CartBottomSheet displays correctly', (WidgetTester tester) async {
    // Arrange
    final testApp = ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const CartBottomSheet(),
                );
              },
              child: const Text('Show Sheet'),
            ),
          ),
        ),
      ),
    );

    // Act
    await tester.pumpWidget(testApp);
    
    // Tap button to show bottom sheet
    await tester.tap(find.text('Show Sheet'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Your cart is empty'), findsOneWidget);
  });
}
