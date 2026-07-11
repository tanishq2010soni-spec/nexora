import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_ai/app.dart';

void main() {
  testWidgets('App renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(PersonalAIApp());

    expect(find.byType(MaterialApp), findsOneWidget);

    await tester.pump();

    expect(find.byType(Scaffold), findsWidgets);
  });
}
