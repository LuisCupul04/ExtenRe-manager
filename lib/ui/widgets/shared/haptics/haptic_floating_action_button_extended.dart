/*
 * Copyright (C) 2022 ReVanced LLC
 * Copyright (C) 2022 inotia00
 * Copyright (C) 2026 LuisCupul04
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticFloatingActionButtonExtended extends StatelessWidget {
  const HapticFloatingActionButtonExtended({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.elevation,
  });
  final Function()? onPressed;
  final Widget label;
  final Widget? icon;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => {
        HapticFeedback.lightImpact(),
        if (onPressed != null) onPressed!(),
      },
      label: label,
      icon: icon,
      elevation: elevation,
    );
  }
}
