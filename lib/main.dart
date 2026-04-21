import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jewello/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jewello/splash/screens/splash_screen.dart';
import 'package:jewello/data/services/auth_service.dart';
import 'package:jewello/features/update/update_guard.dart';
import 'package:jewello/utils/theme/color_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize Firebase (Temp for migration)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://onuedsalshndgnrvmhdf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9udWVkc2Fsc2huZGducnZtaGRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2ODc0NDEsImV4cCI6MjA5MjI2MzQ0MX0.FjzQfC3qrvXXMpcVGXJtqVLNcUryUx2Sz6yDhy0INfE',
  );
  Get.put(AuthService());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: DDSilverColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: DDSilverColors.primary,
          primary: DDSilverColors.primary,
          surface: DDSilverColors.surface,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: DDSilverColors.appBarBG,
          elevation: 0,
          toolbarTextStyle: TextStyle(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const UpdateGuard(child: SplashScreen()),
    );
  }
}
