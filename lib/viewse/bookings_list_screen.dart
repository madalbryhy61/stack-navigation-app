import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'customer_profile_screen.dart'; // استيراد صفحة البروفايل

class BookingsListScreen extends StatelessWidget {
  const BookingsListScreen({super.key});

  // دالة لحذف الحجز وتغيير حالة الغرفة إلى "متاحة"
  Future<void> _checkOut(String bookingId, String roomNo, BuildContext context, LanguageProvider lang) async {
    try {
      // 1. حذف مستند الحجز
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();

      // 2. تحديث حالة الغرفة في مجموعة الـ rooms
      var roomQuery = await FirebaseFirestore.instance
          .collection('rooms')
          .where('no', isEqualTo: roomNo)
          .get();

      if (roomQuery.docs.isNotEmpty) {
        await roomQuery.docs.first.reference.update({'status': 'متاحة'});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.isArabic ? "تم الإخلاء بنجاح" : "Checked out successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(lang.getText('bookings'), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // الخلفية الموحدة
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      lang.isArabic ? "لا توجد حجوزات حالياً" : "No bookings found",
                      style: const TextStyle(color: Colors.white60, fontSize: 18),
                    ),
                  );
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    var b = bookings[index];
                    String docId = b.id;
                    String customerName = b['customer_name'] ?? "";
                    String customerId = b['customer_id'] ?? "";
                    String roomNo = b['room_no'] ?? "";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: ListTile(
                        onTap: () {
                          // الانتقال لصفحة ملف العميل عند الضغط على الصف
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerProfileScreen(
                                customerId: customerId,
                                customerName: customerName,
                              ),
                            ),
                          );
                        },
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          customerName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${lang.getText('rooms')}: $roomNo",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _checkOut(docId, roomNo, context, lang),
                          child: Text(lang.getText('checkout'), style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}