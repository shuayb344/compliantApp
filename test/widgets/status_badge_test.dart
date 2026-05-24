import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:complaint_app/widgets/status_badge.dart';

void main() {
  group('StatusBadge Widget Tests', () {
    testWidgets('should render correct text for pending status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'pending'),
          ),
        ),
      );

      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('should render correct text for resolved status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'resolved'),
          ),
        ),
      );

      expect(find.text('RESOLVED'), findsOneWidget);
    });

    testWidgets('should render correct text for in_progress status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'in_progress'),
          ),
        ),
      );

      expect(find.text('IN PROGRESS'), findsOneWidget);
    });

    testWidgets('should use compact padding when compact is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'pending', compact: true),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final padding = container.padding as EdgeInsets;
      expect(padding.horizontal, 16.0); // 8 * 2
      expect(padding.vertical, 6.0); // 3 * 2
    });
  });
}
