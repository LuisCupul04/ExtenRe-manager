/*
 * Copyright (C) 2022 ReVanced LLC
 * Copyright (C) 2022 inotia00
 * Copyright (C) 2026 LuisCupul04
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

import 'package:extenre_manager/app/app.locator.dart';
import 'package:extenre_manager/services/manager_api.dart';
import 'package:stacked/stacked.dart';

class ContributorsViewModel extends BaseViewModel {
  final ManagerAPI _managerAPI = locator<ManagerAPI>();
  Map<String, List<dynamic>> contributors = {};

  Future<void> getContributors() async {
    contributors = await _managerAPI.getContributors();
    notifyListeners();
  }
}
