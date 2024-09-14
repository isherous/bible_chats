import 'package:bible_chat/Global/constants.dart';
import 'package:dio/dio.dart';

class PineConeServices {
  final pinConeIndex = kPinConeIndexUrl;
  final pinConeAPIKey = kPineconeApiKey;

  Future<List<String>?> searchBible(List<double> vector) async {
    final dio = Dio();
    final url = '$pinConeIndex/query';

    final headers = {
      'Api-Key': pinConeAPIKey,
      'Content-Type': 'application/json',
    };

    final data = {
      // 'namespace': 'default',
      'vector': vector,
      'topK': 15,
      'includeValues': true,
      'includeMetadata': true,
    };

    try {
      final response = await dio.post(
        url,
        options: Options(headers: headers),
        data: data,
      );

      List<String> versesList = [];

      List resultsList = response.data["matches"];
      for (var result in resultsList) {
        String verse = result["metadata"]["text"];
        // print(verse);
        versesList.add(verse);
      }

      return versesList;
      // print(response.data["matches"].first["metadata"]);
    } catch (e) {
      print('PineCone Services Search Bible Error $e');
      return null;
    }
  }
}
