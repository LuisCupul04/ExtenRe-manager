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

class SRequireSuggestedAppVersion extends StatefulWidget {
  const SRequireSuggestedAppVersion({super.key});

  @override
  State<SRequireSuggestedAppVersion> createState() =>
      _SRequireSuggestedAppVersionState();
}

final _settingsViewModel = SettingsViewModel();

class _SRequireSuggestedAppVersionState
    extends State<SRequireSuggestedAppVersion> {
  @override
  Widget build(BuildContext context) {
    return HapticSwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      title: Text(
        t.settingsView.requireSuggestedAppVersionLabel,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(t.settingsView.requireSuggestedAppVersionHint),
      value: _settingsViewModel.isRequireSuggestedAppVersionEnabled(),
      onChanged: (value) async {
        await _settingsViewModel.showRequireSuggestedAppVersionDialog(
          context,
          value,
        );
        setState(() {});
      },
    );
  }
}
