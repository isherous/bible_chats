import 'package:bible_chat/Services/pinecone-services.dart';

import 'firebase-services.dart';
import 'gemini-services.dart';
import 'image-generation-services.dart';

class SearchServices {
  final _geminiServices = GeminiServices();
  final _pinconeServices = PineConeServices();
  final _imageServices = ImageGenerationServices();
  final _firebaseServices = FirebaseServices();

  Future<String> fullSearch({
    required String query,
    bool isSuggestion = false,
  }) async {
    String answer = "";

    ///Getting Embeddings
    List<double>? vectors =
        await _geminiServices.convertTextToEmbeddings(query);

    if (vectors == null) {
      answer = "Could not convert text to embeddings";

      ///Storing message to Firebase
      await _firebaseServices.sendMessage(
        question: query,
        answer: answer,
        isSuggestion: isSuggestion,
      );

      return answer;
    }

    print("Text to Embeddings Done");

    ///Vector Search
    List<String>? versesList = await _pinconeServices.searchBible(vectors);

    if (versesList == null) {
      answer = "Vector Search could not happen";

      ///Storing message to Firebase
      await _firebaseServices.sendMessage(
        question: query,
        answer: answer,
        isSuggestion: isSuggestion,
      );

      return answer;
    }
    print("Vector Search Done");

    ///Getting the answer from the LLM
    Map? responseFromGemini = await _geminiServices.getResponseFromGemini(
      verses: versesList,
      query: query,
    );

    print(responseFromGemini);

    if (responseFromGemini == null) {
      answer = "Gemini LLM didn't return anything";

      ///Storing message to Firebase
      await _firebaseServices.sendMessage(
        question: query,
        answer: answer,
        isSuggestion: isSuggestion,
      );

      return answer;
    }

    bool status = responseFromGemini["status"];
    String messageFromLLM = responseFromGemini["message"];

    ///Storing message to Firebase
    await _firebaseServices.sendMessage(
      question: query,
      answer: messageFromLLM,
      isSuggestion: isSuggestion,
    );
    return messageFromLLM;
    // mainProvider.changeAnswer(messageFromLLM);

    // if (status) {
    //   await _imageServices
    //       .createImageWithLimeWire(responseFromGemini["message"]);
    // }
  }
}
