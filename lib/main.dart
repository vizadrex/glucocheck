
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers.dart';
import 'core/services/notification_service.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/profile/presentation/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Init SharedPrefs
  final sharedPrefs = await SharedPreferences.getInstance();
  
  // Init Notifications
  final notificationService = NotificationService();
  try {
    await notificationService.init();
  } catch (e) {
    debugPrint('Notification Service initialization failed: $e');
  }

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      notificationServiceProvider.overrideWithValue(notificationService),
    ],
    child: GlucocheckApp(onboardingComplete: sharedPrefs.getBool('completed_onboarding') ?? false),
  ));
}

class GlucocheckApp extends StatelessWidget {
  final bool onboardingComplete;
  const GlucocheckApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GLUCOCHECK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B), // Teal for health/calm
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      home: onboardingComplete ? const DashboardScreen() : const OnboardingScreen(),
    );
  }
}
