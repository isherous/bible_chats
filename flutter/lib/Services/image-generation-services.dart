import 'package:bible_chat/Global/constants.dart';
import 'package:dio/dio.dart';

class ImageGenerationServices {
  final dio = Dio();
  final url = 'https://api.limewire.com/api/image/generation';
  final limeWireAPI = kLimeWireApiKey;

  Future<String?> createImageWithLimeWire(String answer) async {
    // String bibleContext = verses.join('\n');

    // String prompt = "Create an image according to the following Bible verses."
    //     "$bibleContext";

    String prompt =
        "Create an image according to the text regarding Bible / Christianity."
        "$answer";

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $limeWireAPI',
      'Content-Type': 'application/json',
      'X-Api-Version': 'v1',
    };

    final data = {
      'prompt': prompt,
      // 'samples': 1,
      // 'quality': 'LOW',
      // 'guidance_scale': 25,
      'aspect_ratio': '1:1',
      // 'style': 'NONE',
    };

    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: headers,
          contentType: Headers.jsonContentType,
        ),
        data: data,
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Response data: ${response.data}');
      }
      return null;
    } catch (e) {
      print('Image Generation Create Image LimeWrite Error : $e');
      return null;
    }
  }
}
