import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  final db = FirebaseFirestore.instance;

  Future<void> sendMessage(String message) async {
    ///Adding a message
    await db.collection("messages").add({"message": message});
  }
}
