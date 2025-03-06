import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warm_faces/features/Instructions/screens/splash_screen.dart';
import 'package:warm_faces/features/Instructions/screens/instruction_screen.dart';
import 'package:warm_faces/features/authentication/screens/signin_screen.dart';

// Mock class for SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Custom NavigatorObserver to mock navigation
class CustomNavigatorObserver extends NavigatorObserver {
  List<Route> routes = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    routes.add(route);
    super.didPush(route, previousRoute);
  }

  bool didPushCalledWithType(Type screenType) {
    return routes.any((route) => route.settings.name == screenType.toString());
  }
}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late CustomNavigatorObserver customNavigatorObserver;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    customNavigatorObserver = CustomNavigatorObserver();
    SharedPreferences.setMockInitialValues({});
  });

  group('SplashScreen - Unit Tests', () {
    testWidgets('should navigate to InstructionScreen on first launch',
        (WidgetTester tester) async {
      // Mock SharedPreferences to simulate a first launch
      when(() => mockSharedPreferences.getBool('isFirstLaunch'))
          .thenReturn(null);

      when(() => mockSharedPreferences.setBool('isFirstLaunch', false))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          navigatorObservers: [customNavigatorObserver],
        ),
      );

      // Simulate the splash screen delay
      await tester.pump(const Duration(seconds: 5));

      // Check if InstructionScreen was pushed
      expect(customNavigatorObserver.didPushCalledWithType(InstructionScreen),
          true);
    });

    testWidgets('should navigate to SigninScreen on subsequent launch',
        (WidgetTester tester) async {
      when(() => mockSharedPreferences.getBool('isFirstLaunch'))
          .thenReturn(false);

      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          navigatorObservers: [customNavigatorObserver],
        ),
      );

      // Simulate the splash screen delay
      await tester.pump(const Duration(seconds: 5));

      // Check if SigninScreen was pushed
      expect(customNavigatorObserver.didPushCalledWithType(SigninScreen), true);
    });
  });
}
