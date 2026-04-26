import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hotels/viewse/login_screen.dart';
import 'package:provider/provider.dart';
import 'viewse/language_provider.dart';
import 'viewse/dashboard_screen.dart';
import 'firebase_options.dart'; // هذا يبقى كما هو لأنه في نفس مستوى main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Empire Hotel',
      // دعم اللغات رسمياً في MaterialApp
      locale: lang.isArabic ? const Locale('ar') : const Locale('en'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: lang.isArabic ? 'Cairo' : 'Roboto', // تحسين الخطوط بناءً على اللغة
      ),
      home: const LoginScreen(),
    );
  }
}