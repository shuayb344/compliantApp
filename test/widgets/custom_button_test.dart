import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:complaint_app/widgets/custom_button.dart';

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('should render text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('should show loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Click Me',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Click Me'), findsNothing);
    });

    testWidgets('should trigger onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Click Me',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      expect(pressed, true);
    });

    testWidgets('should be disabled when isLoading is true', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Click Me',
              onPressed: () {
                pressed = true;
              },
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      expect(pressed, false);
    });
  });
}
