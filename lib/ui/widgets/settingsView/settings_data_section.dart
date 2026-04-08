/*
 * Copyright (C) 2022 ReVanced LLC
 * Copyright (C) 2022 inotia00
 * Copyright (C) 2026 LuisCupul04
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:extenre_manager/gen/strings.g.dart';
import 'package:extenre_manager/ui/views/settings/settingsFragment/settings_manage_api_url.dart';
import 'package:extenre_manager/ui/views/settings/settingsFragment/settings_manage_sources.dart';
import 'package:extenre_manager/ui/widgets/settingsView/settings_section.dart';
import 'package:extenre_manager/ui/widgets/settingsView/settings_use_prereleases.dart';

class SDataSection extends StatelessWidget {
  const SDataSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: t.settingsView.dataSectionTitle,
      children: const <Widget>[
        SManageApiUrlUI(),
        SManageSourcesUI(),
        SUsePrereleases(),
      ],
    );
  }
}
