import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:time_matrix/main_common.dart';
import 'package:time_matrix/main_injection_container.dart' as di;

void main() {
  testWidgets('Matrix page renders the four quadrants', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await di.init();

    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TimeMatrixApp());
    await tester.pumpAndSettle();

    expect(find.text('Time Matrix'), findsOneWidget);
    expect(find.text('Do First'), findsOneWidget);
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Delegate'), findsOneWidget);
    expect(find.text('Eliminate'), findsOneWidget);
  });
}
