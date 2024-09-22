import 'package:dio/dio.dart';

class IpServices {
  Dio dio = Dio();

  Future<Map?> fetchIpAddress() async {
    try {
      final response = await dio.get('https://api.ipify.org?format=json');
      print(response.data);
      return response.data;
    } catch (e) {
      print("Ip Services Fetch Ip Address Error $e");
      return null;
    }
  }
}
