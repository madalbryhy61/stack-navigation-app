import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart'; // تأكد من المسار
import 'dashboard_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lang.isArabic ? "إنشاء حساب" : "Sign Up",
                style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // حقل الإيميل
              SizedBox(
                width: 300,
                child: TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: lang.isArabic ? 'البريد الإلكتروني' : 'Email Address',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // حقل كلمة المرور
              SizedBox(
                width: 300,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: lang.isArabic ? 'كلمة المرور' : 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // زر إنشاء حساب (تم توحيده مع زر Login)
              SizedBox(
                width: 300,
                height: 55, // نفس حجم زر الدخول
                child: ElevatedButton(
                  onPressed: () async {
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      showMessage(lang.isArabic ? "أدخل جميع البيانات" : "Enter all data");
                      return;
                    }

                    try {
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'email-already-in-use') {
                        showMessage(lang.isArabic ? "الإيميل مستخدم مسبقاً" : "Email already in use");
                      } else if (e.code == 'weak-password') {
                        showMessage(lang.isArabic ? "كلمة المرور ضعيفة" : "Weak password");
                      } else {
                        showMessage(e.message ?? "Error");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // نفس لون زر الدخول
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // نفس الحواف
                    ),
                  ),
                  child: Text(
                    lang.isArabic ? 'إنشاء حساب' : 'Sign Up',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}