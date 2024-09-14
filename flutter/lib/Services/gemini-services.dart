import 'dart:convert';

import 'package:bible_chat/Global/constants.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServices {
  ///Models
  final geminiFlashModel = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: kGeminiApiKey,
  );

  final geminiEmbeddingModel = GenerativeModel(
    model: 'text-embedding-004',
    apiKey: kGeminiApiKey,
  );

  ///Converting the input text into Embeddings
  Future<List<double>?> convertTextToEmbeddings(String text) async {
    final content = Content.text(text);
    final result = await geminiEmbeddingModel.embedContent(content);
    return result.embedding.values;
  }

  ///Getting the response back from LLM for the User
  Future<Map?> getResponseFromGemini({
    required List<String> verses,
    required String query,
  }) async {
    String bibleContext = verses.join('\n');

    String prompt =
        "You are a Bible Bot. You will be given context which will be a verse of Bible."
        "The `query` will be asked according to the Bible."
        "Your job is to answer the `query` related to the `context` you will get."
        "Make sure your answers are easy to understand."
        "Make sure your answers are brief."
        "Make sure your answers are respectable"
        "If the query doesn't look like a question related to Bible or Christianity in general,"
        "kindly apologise and ask for another question"
        "Return your response in json format only with `status` and `message` values."
        "Do not include any json indication."
        "If the question is related to bible or christianity then return `true`. "
        "If not, then the status should be `false`."
        "The reply message should be in the key `message`."
        "`Context` : $bibleContext"
        "`Query` : $query";

    final content = [Content.text(prompt)];
    final response = await geminiFlashModel.generateContent(content);
    String? responseText = response.text;
    Map<String, dynamic> map = {
      "status": false,
      "message": "There was an error"
    };
    if (responseText != null) {
      map = jsonDecode(responseText);
    }
    return map;
  }
}
