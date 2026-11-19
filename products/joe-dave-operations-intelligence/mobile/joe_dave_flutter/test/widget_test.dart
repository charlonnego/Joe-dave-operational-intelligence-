import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joe_dave_operations/main.dart';

void main() {
  testWidgets('native Joe&dave sign-in screen renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(onLogin: (token, profile) async {})),
    );
    expect(find.text('Joe&dave'), findsOneWidget);
    expect(find.text('Operations Intelligence'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
