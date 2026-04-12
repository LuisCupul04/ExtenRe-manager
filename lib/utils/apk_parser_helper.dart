import 'dart:typed_data';
import 'package:android_apk_parser/android_apk_parser.dart';
import 'package:device_apps/device_apps.dart';

class ApkParserHelper {
  /// Obtiene la información de un archivo APK externo.
  /// Retorna un mapa con: packageName, versionName, appName, icon (si la app está instalada), apkFilePath.
  static Future<Map<String, dynamic>?> getAppInfoFromApk(String apkFilePath) async {
    try {
      final parser = AndroidApkParser(apkFilePath);
      await parser.parse();
      final packageName = parser.packageName;
      final versionName = parser.versionName;
      final appName = parser.appName ?? packageName;

      // Intentar obtener el icono si la app ya está instalada
      Uint8List? icon;
      final installedApp = await DeviceApps.getApp(packageName, true);
      if (installedApp != null && installedApp is ApplicationWithIcon) {
        icon = installedApp.icon;
      }

      return {
        'packageName': packageName,
        'versionName': versionName,
        'appName': appName,
        'icon': icon ?? Uint8List(0),
        'apkFilePath': apkFilePath,
      };
    } catch (e) {
      print('Error parsing APK: $e');
      return null;
    }
  }
}
