import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({super.key});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final TextEditingController nameController = TextEditingController();
  String? selectedRoom; // لتخزين رقم الغرفة المختارة من القائمة
  DateTime entryDate = DateTime.now();
  DateTime exitDate = DateTime.now().add(const Duration(days: 1));

  Future<void> _selectDate(BuildContext context, bool isEntry) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isEntry ? entryDate : exitDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isEntry) entryDate = picked;
        else exitDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(lang.isArabic ? "حجز جديد" : "New Booking", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/bg.jpg'), fit: BoxFit.cover))),
          Container(color: Colors.black.withOpacity(0.7)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  // حقل الاسم
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(lang.isArabic ? "اسم العميل" : "Customer Name"),
                  ),
                  const SizedBox(height: 20),

                  // القائمة المنسدلة للغرف المتاحة فقط
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('rooms').where('status', isEqualTo: 'متاحة').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();

                      var roomDocs = snapshot.data!.docs;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: Colors.grey[900],
                            hint: Text(lang.isArabic ? "اختر غرفة متاحة" : "Select Available Room", style: const TextStyle(color: Colors.white70)),
                            value: selectedRoom,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            items: roomDocs.map((doc) {
                              return DropdownMenuItem<String>(
                                value: doc['no'].toString(),
                                child: Text("${lang.isArabic ? "غرفة" : "Room"} ${doc['no']}", style: const TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => selectedRoom = val),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  _dateTile(lang.isArabic ? "تاريخ الدخول" : "Entry Date", entryDate, () => _selectDate(context, true)),
                  const SizedBox(height: 15),
                  _dateTile(lang.isArabic ? "تاريخ الخروج" : "Exit Date", exitDate, () => _selectDate(context, false)),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () async {
                        if (nameController.text.isEmpty || selectedRoom == null) return;

                        // 1. إضافة الحجز
                        await FirebaseFirestore.instance.collection('bookings').add({
                          'customer_name': nameController.text,
                          'customer_id': user?.email?.toLowerCase().trim(),
                          'room_no': selectedRoom,
                          'entry_date': entryDate,
                          'exit_date': exitDate,
                        });

                        // 2. تحديث حالة الغرفة المختارة لتصبح "مشغولة"
                        var roomSnap = await FirebaseFirestore.instance.collection('rooms').where('no', isEqualTo: selectedRoom).get();
                        if (roomSnap.docs.isNotEmpty) {
                          await roomSnap.docs.first.reference.update({'status': 'مشغولة'});
                        }

                        Navigator.pop(context);
                      },
                      child: Text(lang.isArabic ? "تأكيد الحجز" : "Confirm Booking", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label, labelStyle: const TextStyle(color: Colors.white70),
      filled: true, fillColor: Colors.white.withOpacity(0.1),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white24)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blueAccent)),
    );
  }

  Widget _dateTile(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white24)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text("${date.year}-${date.month}-${date.day}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}