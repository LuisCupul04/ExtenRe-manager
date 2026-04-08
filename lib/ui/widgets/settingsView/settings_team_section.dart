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
import 'package:extenre_manager/ui/widgets/settingsView/settings_section.dart';
import 'package:extenre_manager/ui/widgets/settingsView/social_media_widget.dart';

final _settingsViewModel = SettingsViewModel();

class STeamSection extends StatelessWidget {
  const STeamSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: t.settingsView.teamSectionTitle,
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          title: Text(
            t.settingsView.contributorsLabel,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(t.settingsView.contributorsHint),
          onTap: () => _settingsViewModel.navigateToContributors(),
        ),
        const SocialMediaWidget(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
        ),
      ],
    );
  }
}
