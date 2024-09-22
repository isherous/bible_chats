import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  final db = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String question,
    required String answer,
  }) async {
    ///Adding a message
    await db.collection("messages").add(
      {
        "question": question,
        "answer": answer,
        "time": DateTime.now(),
      },
    );
  }
}
