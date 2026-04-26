import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isArabic = true;
  bool get isArabic => _isArabic;

  void toggleLanguage() {
    _isArabic = !_isArabic;
    notifyListeners();
  }

  String getText(String key) {
    Map<String, Map<String, String>> data = {
      'app_title': {'ar': 'فندق الإمبراطورية', 'en': 'Empire Hotel'},
      'new_booking': {'ar': 'حجز جديد +', 'en': 'New Booking +'},
      'rooms': {'ar': 'الغرف', 'en': 'Rooms'},
      'bookings': {'ar': 'الحجوزات', 'en': 'Bookings'},
      'reports': {'ar': 'التقارير', 'en': 'Reports'},
      'home': {'ar': 'الرئيسية', 'en': 'Home'},
      'available': {'ar': 'متاحة', 'en': 'Available'},
      'occupied': {'ar': 'مشغولة', 'en': 'Occupied'},
      'maintenance': {'ar': 'صيانة', 'en': 'Maintenance'},
      'cust_name': {'ar': 'اسم العميل', 'en': 'Customer Name'},
      'id_num': {'ar': 'رقم الهوية', 'en': 'ID Number'},
      'select_room': {'ar': 'اختر الغرفة', 'en': 'Select Room'},
      'entry_date': {'ar': 'تاريخ الدخول', 'en': 'Entry Date'},
      'exit_date': {'ar': 'تاريخ الخروج', 'en': 'Exit Date'},
      'confirm': {'ar': 'تأكيد الحجز', 'en': 'Confirm Booking'},
      'checkout': {'ar': 'إخلاء', 'en': 'Check-out'},
      'total': {'ar': 'الإجمالي', 'en': 'Total'},
      'days': {'ar': 'أيام', 'en': 'Days'},
    };
    return data[key]?[_isArabic ? 'ar' : 'en'] ?? key;
  }
}