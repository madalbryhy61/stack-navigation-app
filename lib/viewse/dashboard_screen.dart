import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ضروري لجلب بيانات المستخدم الحالي
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'rooms_screen.dart';
import 'add_booking_screen.dart';
import 'bookings_list_screen.dart';
import 'reports_screen.dart';
import 'login_screen.dart';
import 'customer_profile_screen.dart'; // استيراد صفحة البروفايل

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // دالة الحماية بكلمة سر (1234)
  void _secureNavigate(BuildContext context, Widget target, String title) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: lang.isArabic ? "أدخل كلمة السر" : "Enter Password",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(lang.isArabic ? "إلغاء" : "Cancel")),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text == "1234") {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => target));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(lang.isArabic ? "كلمة السر خاطئة!" : "Wrong Password!")),
                );
              }
            },
            child: Text(lang.isArabic ? "دخول" : "Login"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final user = FirebaseAuth.instance.currentUser; // المستخدم الحالي

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.language, color: Colors.white),
          onPressed: () => lang.toggleLanguage(),
        ),
        title: Text(lang.getText('app_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // 1. أيقونة تقرير العميل (الحساب الحالي)
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.blueAccent, size: 32),
            onPressed: () {
              if (user != null) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CustomerProfileScreen(
                    customerId: user.email!, // نستخدم الإيميل كمفتاح للبحث
                    customerName: user.email!.split('@')[0], // اسم مستعار من الإيميل
                  ),
                ));
              }
            },
          ),
          // 2. زر تسجيل الخروج
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/bg.jpg'), fit: BoxFit.cover),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // شريط الإحصائيات (متاحة، مشغولة، صيانة)
                _buildStatusRow(lang),

                const SizedBox(height: 35), // مسافة لتحريك زر الحجز للأعلى (مثل الـ PDF)

                // زر حجز جديد في مكانه الصحيح (تحت الإحصائيات)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddBookingScreen())),
                    child: Text(lang.getText('new_booking'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                const Spacer(), // يدفع بقية المحتوى للأسفل لترك فراغ في المنتصف

                // شريط التنقل السفلي
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(context, Icons.bar_chart, lang.getText('reports'),
                          onTap: () => _secureNavigate(context, const ReportsScreen(), lang.isArabic ? "تقارير الإدارة" : "Admin Reports")),
                      _navItem(context, Icons.book_online, lang.getText('bookings'),
                          onTap: () => _secureNavigate(context, const BookingsListScreen(), lang.isArabic ? "سجل الحجوزات" : "Bookings Log")),
                      _navItem(context, Icons.door_front_door, lang.getText('rooms'),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomsScreen()))),
                      _navItem(context, Icons.home, lang.getText('home'), onTap: () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(LanguageProvider lang) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        int available = snapshot.data!.docs.where((d) => d['status'] == "متاحة").length;
        int occupied = snapshot.data!.docs.where((d) => d['status'] == "مشغولة").length;
        int maintenance = snapshot.data!.docs.where((d) => d['status'] == "صيانة").length;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statusBox(lang.getText('maintenance'), maintenance.toString(), Colors.orange),
            _statusBox(lang.getText('occupied'), occupied.toString(), Colors.redAccent),
            _statusBox(lang.getText('available'), available.toString(), Colors.greenAccent),
          ],
        );
      },
    );
  }

  Widget _statusBox(String label, String count, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}