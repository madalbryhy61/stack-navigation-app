import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

class CustomerProfileScreen extends StatelessWidget {
  final String customerId;
  final String customerName;

  const CustomerProfileScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(lang.isArabic ? "ملف العميل" : "Customer Profile",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // الخلفية الموحدة للتطبيق
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.7)),

          SafeArea(
            child: Column(
              children: [
                // كرت معلومات العميل العلوية
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customerName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text("${lang.getText('id_num')}: $customerId",
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Align(
                    alignment: lang.isArabic ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      lang.isArabic ? "سجل الحجوزات" : "Booking History",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // عرض الحجوزات من Firebase
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('customer_id', isEqualTo: customerId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var history = snapshot.data!.docs;

                      if (history.isEmpty) {
                        return Center(
                          child: Text(
                            lang.isArabic ? "لا توجد حجوزات سابقة" : "No previous bookings",
                            style: const TextStyle(color: Colors.white60),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          var booking = history[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.hotel, color: Colors.blueAccent),
                              title: Text(
                                "${lang.getText('rooms')} ${booking['room_no']}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "${lang.getText('entry_date')}: ${booking['entry_date'].toDate().toString().split(' ')[0]}",
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.white24),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}