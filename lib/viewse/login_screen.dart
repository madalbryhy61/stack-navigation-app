import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart'; // تأكد من اسم ملف الـ Signup عندك

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
        child: Container(
          color: Colors.black.withOpacity(0.6), // تعتيم الخلفية لزيادة الوضوح
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hotel_class, size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    lang.isArabic ? "تسجيل الدخول" : "Login",
                    style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),

                  // حقل الإيميل
                  SizedBox(
                    width: 320,
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
                    width: 320,
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

                  // زر تسجيل الدخول (مطابق تماماً لزر إنشاء الحساب)
                  SizedBox(
                    width: 320,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          showMessage(lang.isArabic ? "أدخل جميع البيانات" : "Enter all data");
                          return;
                        }

                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                          );
                        } on FirebaseAuthException catch (e) {
                          showMessage(lang.isArabic ? "خطأ في البريد أو كلمة السر" : "Invalid Email or Password");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // اللون الموحد
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // نفس الحواف
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        lang.isArabic ? 'دخول' : 'Login',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // رابط إنشاء حساب جديد بنفس تنسيق الخط
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: Text(
                      lang.isArabic ? "ليس لديك حساب؟ سجل الآن" : "Don't have an account? Sign Up",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}