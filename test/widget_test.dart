import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handball_app/main.dart';

void main() {
  testWidgets('La app inicia correctamente sin errores', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GoalKeeperApp());

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}