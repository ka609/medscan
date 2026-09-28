import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

import 'providers/auth_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/consultation_provider.dart';
import 'providers/prescription_provider.dart';
import 'providers/imaging_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MedScanApp());
}

class MedScanApp extends StatelessWidget {
  const MedScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PatientProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ConsultationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PrescriptionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ImagingProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'MedScan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}