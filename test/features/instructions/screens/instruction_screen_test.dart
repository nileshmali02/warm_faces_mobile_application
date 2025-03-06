import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warm_faces/features/Instructions/screens/instruction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Group the tests related to InstructionScreen
  group('InstructionScreen Tests', () {
    setUp(() {
      // Set up the initial SharedPreferences values
      SharedPreferences.setMockInitialValues({
        'dontShowAgain': false, // Default value
      });
    });

    testWidgets('should display onboarding screens and manage page navigation',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: InstructionScreen(),
      ));

      // Ensure the first page is displayed
      expect(find.text('Welcome to Warm Faces'), findsOneWidget);

      // Navigate to the next page by tapping the Next button
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle(); // Wait for the transition to complete

      // Ensure the second page is displayed
      expect(find.text('Receive Warmth'), findsOneWidget);

      // Navigate to the last page by tapping the Next button again
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle(); // Wait for the transition to complete

      // Ensure the last page is displayed
      expect(find.text('Give Warmth'), findsOneWidget);

      // Tap on the Next button to navigate to the SigninScreen
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle(); // Wait for the transition to complete

      // At this point, the SigninScreen should be displayed (you can test that here)
      // This is a navigation test, so no direct widget to assert here unless we mock the SigninScreen.
    });

    testWidgets('should load checkbox state from SharedPreferences',
        (WidgetTester tester) async {
      // Set SharedPreferences to return true for the checkbox
      SharedPreferences.setMockInitialValues({'dontShowAgain': true});

      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: InstructionScreen(),
      ));

      // Ensure that the checkbox is checked (because the state is true)
      expect(find.byType(Checkbox), findsOneWidget);
      expect((tester.widget(find.byType(Checkbox)) as Checkbox).value, true);
    });

    testWidgets(
        'should update checkbox state in SharedPreferences when changed',
        (WidgetTester tester) async {
      // Set SharedPreferences to return false initially
      SharedPreferences.setMockInitialValues({'dontShowAgain': false});

      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: InstructionScreen(),
      ));

      // Tap on the checkbox to change its state to true
      await tester.tap(find.byType(Checkbox));
      await tester.pump(); // Rebuild widget to reflect the state change

      // Ensure the checkbox is now checked
      expect((tester.widget(find.byType(Checkbox)) as Checkbox).value, true);

      // You can verify that SharedPreferences setBool has been called with the right parameters
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('dontShowAgain'), true);
    });

    testWidgets('should not show the onboarding if checkbox is checked',
        (WidgetTester tester) async {
      // Mock SharedPreferences to return true for the checkbox
      SharedPreferences.setMockInitialValues({'dontShowAgain': true});

      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: InstructionScreen(),
      ));

      // Ensure that the widget is replaced with SigninScreen (no widget should be rendered)
      expect(find.byType(Scaffold), findsNothing); // The screen should be empty
    });
  });
}
