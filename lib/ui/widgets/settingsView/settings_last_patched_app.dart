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
import 'package:extenre_manager/ui/widgets/shared/haptics/haptic_switch_list_tile.dart';

class SLastPatchedApp extends StatefulWidget {
  const SLastPatchedApp({super.key});

  @override
  State<SLastPatchedApp> createState() =>
      _SLastPatchedAppState();
}

final _settingsViewModel = SettingsViewModel();

class _SLastPatchedAppState
    extends State<SLastPatchedApp> {
  @override
  Widget build(BuildContext context) {
    return HapticSwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      title: Text(
        t.settingsView.lastPatchedAppLabel,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(t.settingsView.lastPatchedAppHint),
      value: _settingsViewModel.isLastPatchedAppEnabled(),
      onChanged: (value) {
        setState(() {
          _settingsViewModel.useLastPatchedApp(value);
        });
      },
    );
  }
}
