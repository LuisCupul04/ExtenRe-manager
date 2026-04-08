/*
 * Copyright (C) 2022 ReVanced LLC
 * Copyright (C) 2022 inotia00
 * Copyright (C) 2026 LuisCupul04
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

import 'package:flutter/material.dart';
import 'package:extenre_manager/gen/strings.g.dart';
import 'package:extenre_manager/ui/views/settings/settings_viewmodel.dart';
import 'package:extenre_manager/ui/widgets/settingsView/about_widget.dart';
import 'package:extenre_manager/ui/widgets/settingsView/settings_section.dart';

final _settingsViewModel = SettingsViewModel();

class SDebugSection extends StatelessWidget {
  const SDebugSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: t.settingsView.debugSectionTitle,
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          title: Text(
            t.settingsView.logsLabel,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(t.settingsView.logsHint),
          onTap: () => _settingsViewModel.exportLogcatLogs(),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          title: Text(
            t.settingsView.deleteLogsLabel,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(t.settingsView.deleteLogsHint),
          onTap: () => _settingsViewModel.deleteLogs(),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          title: Text(
            t.settingsView.deleteTempDirLabel,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(t.settingsView.deleteTempDirHint),
          onTap: () => _settingsViewModel.deleteTempDir(),
        ),
        const AboutWidget(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
        ),
      ],
    );
  }
}
