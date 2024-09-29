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

  List kSuggestions = [
    "How do you seek first the kingdom of God?",
    "Is Believing Jesus Is God Essential for Salvation?",
    "Did God really flood the entire earth?",
    "Why did Satan rebel against God?",
    "Why did Giants eat people?",
  ];

  void removeSuggestFromList(String suggestion) {
    kSuggestions.remove(suggestion);
  }
}
