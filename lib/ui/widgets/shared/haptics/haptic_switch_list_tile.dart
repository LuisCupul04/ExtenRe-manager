/*
 * Copyright (C) 2022 ReVanced LLC
 * Copyright (C) 2022 inotia00
 * Copyright (C) 2026 LuisCupul04
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticSwitchListTile extends StatelessWidget {
  const HapticSwitchListTile({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.contentPadding,
  });
  final bool value;
  final Function(bool)? onChanged;
  final Widget? title;
  final Widget? subtitle;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: contentPadding ?? EdgeInsets.zero,
      title: title,
      subtitle: subtitle,
      value: value,
      onChanged: (value) => {
        if (value) {
          HapticFeedback.mediumImpact(),
        } else {
          HapticFeedback.lightImpact(),
        },
        if (onChanged != null) onChanged!(value),
      },
    );
  }
}
