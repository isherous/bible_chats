import 'package:bible_chat/Global/colors.dart';
import 'package:bible_chat/Global/styles.dart';
import 'package:bible_chat/Providers/main-provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Services/firebase-services.dart';
import '../Services/gemini-services.dart';
import '../Services/image-generation-services.dart';
import '../Services/pinecone-services.dart';

final _geminiServices = GeminiServices();
final _pinconeServices = PineConeServices();
final _imageServices = ImageGenerationServices();
final _firebaseServices = FirebaseServices();

class SearchButton extends StatelessWidget {
  const SearchButton({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.watch<MainProvider>();

    return InkWell(
      onTap: () async {
        String query = controller.text;

        print("Start");

        if (query.isEmpty) {
          return;
        }

        mainProvider.changeQuestion(query);
        mainProvider.changeShowProgress(true);

        controller.clear();

        ///Getting Embeddings
        List<double>? vectors =
            await _geminiServices.convertTextToEmbeddings(query);

        if (vectors == null) {
          ///Storing message to Firebase
          _firebaseServices.sendMessage(
              question: query, answer: "Could not convert text to embeddings");
          mainProvider.changeAnswer("Could not convert text to embeddings");
          mainProvider.changeShowProgress(false);
          return;
        }

        print("Text to Embeddings Done");

        ///Vector Search
        List<String>? versesList = await _pinconeServices.searchBible(vectors);

        if (versesList == null) {
          ///Storing message to Firebase
          _firebaseServices.sendMessage(
              question: query, answer: "Vector Search could not happen");

          mainProvider.changeAnswer("Vector Search could not happen");
          mainProvider.changeShowProgress(false);
          return;
        }
        print("Vector Search Done");

        ///Getting the answer from the LLM
        Map? responseFromGemini = await _geminiServices.getResponseFromGemini(
          verses: versesList,
          query: query,
        );

        print(responseFromGemini);

        if (responseFromGemini == null) {
          ///Storing message to Firebase
          _firebaseServices.sendMessage(
              question: query, answer: "Gemini LLM didn't return anything");

          mainProvider.changeAnswer("Gemini LLM didn't return anything");
          mainProvider.changeShowProgress(false);
          return;
        }

        bool status = responseFromGemini["status"];
        String messageFromLLM = responseFromGemini["message"];

        ///Storing message to Firebase
        _firebaseServices.sendMessage(question: query, answer: messageFromLLM);

        mainProvider.changeAnswer(messageFromLLM);
        mainProvider.changeShowProgress(false);

        // if (status) {
        //   await imageServices.createImageWithLimeWire(
        //       responseFromGemini["message"]);
        // }
      },
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          color: kPeach,
          // color: kGreen,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Center(
          child: Text(
            "Search",
            style: k15Medium.copyWith(height: 1),
          ),
        ),
      ),
    );
  }
}
