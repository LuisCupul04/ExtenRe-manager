import 'dart:async';
import 'package:flutter/services.dart';

class ApkParserService {
  static const MethodChannel _channel = MethodChannel('com.extenre.manager/apk_parser');

  static Future<Map<String, String>> parseApk(String apkPath) async {
    try {
      final Map<String, dynamic> result = await _channel.invokeMethod('parseApk', {
        'apkPath': apkPath,
      });
      // Convertir a Map<String, String> (los valores vienen como String)
      return Map.from(result).map((key, value) => MapEntry(key as String, value.toString()));
    } on PlatformException catch (e) {
      print("Failed to parse APK: ${e.message}");
      rethrow;
    }
  }
}
