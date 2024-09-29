import 'package:bible_chat/Services/attribution-services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  final db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final attributionServices = AttributionServices();

  Future<void> sendMessage({
    required String question,
    required String answer,
    required bool isSuggestion,
  }) async {
    String? userId;
    User? user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
    }

    ///Adding a message
    await db.collection("messages").add(
      {
        "question": question,
        "answer": answer,
        "time": DateTime.now(),
        "isSuggestion": isSuggestion,
        "user": userId,
      },
    );
  }

  Future<String?> signInUser() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      return userCredential.user?.uid;
    } catch (e) {
      print("Firebase Services Sign In User Error $e");
      return null;
    }
  }

  ///Adding user info when they are signed in
  Future<void> storingUserInfo(String uid) async {
    try {
      String? userIp = await attributionServices.fetchIpAddress();
      String screenSize = attributionServices.getScreenSize();
      String browserInfo = attributionServices.getBrowserInfo();
      String userLanguage = attributionServices.getUserLanguage();
      await db.collection("users").doc(uid).set({
        "user-ip": userIp,
        "screen-size": screenSize,
        "browser": browserInfo,
        "language": userLanguage,
        "time": DateTime.now(),
      });
    } catch (e) {
      print("Firebase Services Storing User Info Error $e");
    }
  }
}
