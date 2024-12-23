// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Kiểm tra tiêu đề app', (WidgetTester tester) async {
    // Build ứng dụng
    await tester.pumpWidget(MyApp());

    // Tìm tiêu đề "Spiderum"
    expect(find.text('Spiderum'), findsOneWidget);
    expect(find.text('Không có tiêu đề này'), findsNothing);
  });

  testWidgets('Kiểm tra nút điều hướng', (WidgetTester tester) async {
    // Build ứng dụng
    await tester.pumpWidget(MyApp());

    // Kiểm tra nút 'Trang chủ' có tồn tại
    expect(find.text('Trang chủ'), findsOneWidget);

    // Kiểm tra nút 'Chủ đề' có tồn tại
    expect(find.text('Chủ đề'), findsOneWidget);
  });
}
