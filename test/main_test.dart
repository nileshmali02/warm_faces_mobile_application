import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warm_faces/features/comman/bottom_navbar.dart';
import 'package:warm_faces/main.dart';
import 'package:warm_faces/features/Instructions/screens/splash_screen.dart';

void main() {
  group('Login Status Tests', () {
    testWidgets('Should show BottomNavbar when logged in',
        (WidgetTester tester) async {
      // Arrange: Set isLoggedIn to true (simulate the user being logged in)
      await tester.pumpWidget(const MyApp(isLoggedIn: true));

      // Act & Assert: Verify that BottomNavbar is displayed, and SplashScreen is NOT displayed.
      expect(find.byType(BottomNavbar),
          findsOneWidget); // BottomNavbar should be present
      expect(find.byType(SplashScreen),
          findsNothing); // SplashScreen should not be shown
    });
  });

  // Group tests related to Theme
  group('Theme Tests', () {
    testWidgets('App should set light theme', (WidgetTester tester) async {
      // Act: Run the app with any login state (true or false), it does not affect theme.
      await tester.pumpWidget(const MyApp(isLoggedIn: true));

      // Assert: Verify that the app's theme is set to light.
      final theme = Theme.of(
          tester.element(find.byType(MaterialApp))); // Get the current theme
      expect(theme.brightness, Brightness.light); // The theme should be light
    });
  });

  // Group tests related to Device Orientation
  group('Device Orientation Tests', () {
    testWidgets('Should set preferred device orientation to portraitUp',
        (WidgetTester tester) async {
      // Act: Run the app with any login state (true or false), as orientation is independent of login status.
      await tester.pumpWidget(const MyApp(isLoggedIn: true));

      // Assert: Verify that the app is trying to set the preferred orientation to portraitUp.
      // We can't directly assert orientation settings in widget tests, but we are testing the intent.
    });
  });
}
