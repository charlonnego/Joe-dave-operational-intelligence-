import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joe_dave_operations/main.dart';

void main() {
  testWidgets('native sign-in screen renders Joe&dave identity', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignIn(onSignedIn: (token, profile) async {}),
      ),
    );
    expect(find.text('Joe&dave'), findsOneWidget);
    expect(find.text('Operations Intelligence'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
