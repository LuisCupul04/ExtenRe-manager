/*
 * Copyright (C) 2022 ReVanced LLC
 * Copyright (C) 2022 inotia00
 * Copyright (C) 2026 LuisCupul04
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:extenre_manager/app/app.locator.dart';
import 'package:extenre_manager/gen/strings.g.dart';
import 'package:extenre_manager/services/manager_api.dart';
import 'package:extenre_manager/ui/widgets/settingsView/settings_tile_dialog.dart';
import 'package:stacked/stacked.dart';

class SManageKeystorePassword extends BaseViewModel {
  final ManagerAPI _managerAPI = locator<ManagerAPI>();

  final TextEditingController _keystorePasswordController =
      TextEditingController();

  Future<void> showKeystoreDialog(BuildContext context) async {
    final String keystorePasswordText = _managerAPI.getKeystorePassword();
    _keystorePasswordController.text = keystorePasswordText;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(t.settingsView.selectKeystorePassword),
            ),
            IconButton(
              icon: const Icon(Icons.manage_history_outlined),
              onPressed: () => _keystorePasswordController.text =
                  _managerAPI.defaultKeystorePassword,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _keystorePasswordController,
                autocorrect: false,
                obscureText: true,
                onChanged: (value) => notifyListeners(),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: t.settingsView.selectKeystorePassword,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _keystorePasswordController.clear();
              Navigator.of(context).pop();
            },
            child: Text(t.cancelButton),
          ),
          FilledButton(
            onPressed: () {
              final String passwd = _keystorePasswordController.text;
              _managerAPI.setKeystorePassword(passwd);
              Navigator.of(context).pop();
            },
            child: Text(t.okButton),
          ),
        ],
      ),
    );
  }
}

final sManageKeystorePassword = SManageKeystorePassword();

class SManageKeystorePasswordUI extends StatelessWidget {
  const SManageKeystorePasswordUI({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsTileDialog(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      title: t.settingsView.selectKeystorePassword,
      subtitle: t.settingsView.selectKeystorePasswordHint,
      onTap: () => sManageKeystorePassword.showKeystoreDialog(context),
    );
  }
}
