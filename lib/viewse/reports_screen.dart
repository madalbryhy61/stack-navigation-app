import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(lang.getText('reports'), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.8)),

          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                int totalBookings = snapshot.data!.docs.length;
                double totalRevenue = totalBookings * 150.0; // افتراض 150 لليلة

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // كروت الإحصائيات
                      _buildStatCard(lang.isArabic ? "إجمالي الإيرادات" : "Total Revenue",
                          "\$$totalRevenue", Colors.greenAccent),
                      const SizedBox(height: 15),
                      _buildStatCard(lang.isArabic ? "عدد الحجوزات الكلي" : "Total Bookings",
                          totalBookings.toString(), Colors.blueAccent),

                      const SizedBox(height: 40),

                      // تحليل الإشغال (تمثيل الصفحة 5)
                      Text(
                        lang.isArabic ? "تحليل نسبة الإشغال الأسبوعي" : "Weekly Occupancy Analysis",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        height: 250,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _bar(0.4, "Week 1"),
                            _bar(0.7, "Week 2"),
                            _bar(0.5, "Week 3"),
                            _bar(0.9, "Week 4"),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _bar(double heightPercent, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 35,
          height: 150 * heightPercent,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 8)],
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}