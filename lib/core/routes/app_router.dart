import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/medical/screens/medical_record_screen.dart';
import '../../features/profil/screens/profile_screen.dart';
import '../../features/medical/screens/prescription_screen.dart';
import '../../features/appointments/screens/appointments_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';

  // Application
  static const String main = '/main';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String medicalRecord = '/medical-record';
  static const String prescriptions = '/prescriptions';
  static const String appointments = '/appointments';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,

  routes: [
    // Connexion
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    // Inscription
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) {
        return const RegisterScreen();
      },
    ),

    // Mot de passe oublié
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgot-password',
      builder: (context, state) {
        return const ForgotPasswordScreen();
      },
    ),

    // Vérification OTP
    GoRoute(
      path: AppRoutes.otp,
      name: 'otp',
      builder: (context, state) {
        final email = state.extra as String?;

        return OtpScreen(email: email);
      },
    ),

    // Écran principal
    GoRoute(
      path: AppRoutes.main,
      name: 'main',
      builder: (context, state) {
        return const MainScreen();
      },
    ),

    // Accueil
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) {
        return const HomeScreen();
      },
    ),

    // Profil
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) {
        return const ProfileScreen();
      },
    ),

    // Dossier médical
    GoRoute(
      path: AppRoutes.medicalRecord,
      name: 'medical-record',
      builder: (context, state) {
        return const MedicalRecordScreen();
      },
    ),

    GoRoute(
      path: AppRoutes.prescriptions,
      builder: (context, state) => const PrescriptionScreen(),
    ),

    GoRoute(
  path: AppRoutes.appointments,
  builder: (context, state) {
    return const AppointmentsScreen();
  },
),
  ],

  errorBuilder: (context, state) {
    return ErrorRouteScreen(error: state.error);
  },
);

class ErrorRouteScreen extends StatelessWidget {
  const ErrorRouteScreen({super.key, this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Page introuvable',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Une erreur est survenue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.login);
                },
                child: const Text('Retour à la connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
