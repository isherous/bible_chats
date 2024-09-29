import 'dart:html';

import 'package:dio/dio.dart';

class AttributionServices {
  Dio dio = Dio();

  Future<String?> fetchIpAddress() async {
    try {
      final response = await dio.get('https://api.ipify.org?format=json');
      Map ipMap = response.data;
      return ipMap["ip"];
    } catch (e) {
      print("Ip Services Fetch Ip Address Error $e");
      return null;
    }
  }

  bool isDesktop() {
    String? platformType = window.navigator.platform;
    if (platformType != null) {
      return platformType.contains('Mac') ||
          platformType.contains('Win') ||
          platformType.contains('Linux');
    }
    return false;
  }

  String getScreenSize() {
    final width = window.screen?.width;
    final height = window.screen?.height;
    return "$width x $height";
  }

  String getBrowserInfo() {
    final userAgent = window.navigator.userAgent;
    return userAgent;
  }

  String getUserLanguage() {
    final language = window.navigator.language;
    return language;
  }
}
