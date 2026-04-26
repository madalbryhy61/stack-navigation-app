import 'package:flutter/material.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingDetailsScreen({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    // حساب عدد الأيام
    DateTime entry = bookingData['entry_date'];
    DateTime exit = bookingData['exit_date'];
    int days = exit.difference(entry).inDays;
    if (days <= 0) days = 1; // أقل حجز يوم واحد

    double pricePerDay = 150.0; // افترضنا سعر اليوم 150
    double total = days * pricePerDay;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("تفاصيل الحجز", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.8)),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const Text("تم الحجز بنجاح", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Divider(height: 30),

                  detailRow("اسم العميل:", bookingData['customer_name']),
                  detailRow("رقم الهوية:", bookingData['customer_id']),
                  detailRow("رقم الغرفة:", "غرفة ${bookingData['room_no']}"),
                  detailRow("عدد الأيام:", "$days أيام"),
                  detailRow("سعر اليوم:", "\$$pricePerDay"),
                  const Divider(),
                  detailRow("الإجمالي:", "\$$total", isTotal: true),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text("العودة للرئيسية", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget detailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 16, color: isTotal ? Colors.green : Colors.black, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}