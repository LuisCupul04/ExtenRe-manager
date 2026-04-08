/*
 * Copyright (C) 2022 ReVanced LLC
 * Copyright (C) 2022 inotia00
 * Copyright (C) 2026 LuisCupul04
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

import 'package:flutter/material.dart';
import 'package:extenre_manager/app/app.locator.dart';
import 'package:extenre_manager/gen/strings.g.dart';
import 'package:extenre_manager/services/download_manager.dart';
import 'package:extenre_manager/services/github_api.dart';
import 'package:extenre_manager/services/manager_api.dart';
import 'package:extenre_manager/services/extenre_api.dart';
import 'package:extenre_manager/services/root_api.dart';
import 'package:extenre_manager/ui/theme/dynamic_theme_builder.dart';
import 'package:extenre_manager/ui/views/navigation/navigation_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

late SharedPreferences prefs;
Future main() async {
  await setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await locator<ManagerAPI>().initialize();

  await locator<DownloadManager>().initialize();
  final String apiUrl = locator<ManagerAPI>().getApiUrl();
  await locator<ExtenReAPI>().initialize(apiUrl);
  final String repoUrl = locator<ManagerAPI>().getRepoUrl();
  locator<GithubAPI>().initialize(repoUrl);
  tz.initializeTimeZones();

  // TODO(aAbed): remove in the future, keep it for now during migration.
  final rootAPI = RootAPI();
  if (await rootAPI.hasRootPermissions()) {
    await rootAPI.removeOrphanedFiles();
  }

  prefs = await SharedPreferences.getInstance();

  final managerAPI = locator<ManagerAPI>();
  final locale = managerAPI.getLocale();
  LocaleSettings.setLocaleRaw(locale);

  runApp(TranslationProvider(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const DynamicThemeBuilder(
      title: 'ExtenRe Manager',
      home: NavigationView(),
    );
  }
}
