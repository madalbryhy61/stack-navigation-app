import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(lang.getText('rooms'), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('rooms').orderBy('no').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final rooms = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    var room = rooms[index];
                    String status = room['status'];

                    // تحويل الحالة للنص المترجم
                    String statusKey = status == "متاحة" ? 'available' : (status == "مشغولة" ? 'occupied' : 'maintenance');

                    Color roomColor = status == "متاحة" ? Colors.green : (status == "مشغولة" ? Colors.red : Colors.orange);

                    return GestureDetector(
                      onLongPress: () => _showStatusDialog(context, room.id, room['no'].toString(), lang),
                      child: Container(
                        decoration: BoxDecoration(
                          color: roomColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(room['no'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showStatusDialog(BuildContext context, String docId, String roomNo, LanguageProvider lang) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${lang.getText('rooms')} $roomNo", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(lang.getText('available')),
                onTap: () {
                  FirebaseFirestore.instance.collection('rooms').doc(docId).update({'status': 'متاحة'});
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.build, color: Colors.orange),
                title: Text(lang.getText('maintenance')),
                onTap: () {
                  FirebaseFirestore.instance.collection('rooms').doc(docId).update({'status': 'صيانة'});
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}