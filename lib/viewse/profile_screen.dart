import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // المكتبة الجديدة

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // تعريف المتحكمات للحقول
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadUserData(); // استدعاء دالة الجلب هنا
  }
  Future<void> _loadUserData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc.get('full_name') ?? "";
          _phoneController.text = userDoc.get('phone') ?? "";
        });
      }
    } catch (e) {
      print("خطأ في جلب البيانات: $e");
    }
  }

  // دالة حفظ البيانات في Firestore
  Future<void> _saveProfile() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid; // جلب معرف المستخدم

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': FirebaseAuth.instance.currentUser?.email,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حفظ البيانات بنجاح!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تعديل الملف الشخصي")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "الاسم الكامل",border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: "رقم الهاتف",border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child:ElevatedButton(
              onPressed: _saveProfile,
              child: const Text("حفظ البيانات"),
            ),
          ),
          ],
        ),
      ),
    );
  }
}