import 'package:flutter/material.dart';

class MainProvider extends ChangeNotifier {
  bool showProgress = false;
  void changeShowProgress(bool b) {
    showProgress = b;
    notifyListeners();
  }

  void focusChange({
    required FocusNode focus,
    required BuildContext context,
  }) {
    FocusScope.of(context).requestFocus(focus);
    notifyListeners();
  }

  String? question;
  void changeQuestion(String? ques) {
    question = ques;
    notifyListeners();
  }

  String? answer;
  void changeAnswer(String? ans) {
    answer = ans;
    notifyListeners();
  }
}
