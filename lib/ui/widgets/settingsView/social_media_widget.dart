/*
 * Copyright (C) 2022 ReVanced LLC
 * Copyright (C) 2022 inotia00
 * Copyright (C) 2026 LuisCupul04
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:extenre_manager/gen/strings.g.dart';
import 'package:extenre_manager/ui/widgets/settingsView/social_media_item.dart';
import 'package:extenre_manager/ui/widgets/shared/custom_card.dart';
import 'package:extenre_manager/ui/widgets/shared/custom_icon.dart';

class SocialMediaWidget extends StatelessWidget {
  const SocialMediaWidget({
    super.key,
    this.padding,
  });
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ExpandablePanel(
      theme: ExpandableThemeData(
        hasIcon: true,
        iconColor: Theme.of(context).iconTheme.color,
        iconPadding: const EdgeInsets.symmetric(vertical: 16.0)
            .add(padding ?? EdgeInsets.zero)
            .resolve(Directionality.of(context)),
        animationDuration: const Duration(milliseconds: 400),
      ),
      header: ListTile(
        contentPadding: padding ?? EdgeInsets.zero,
        title: Text(
          t.socialMediaCard.widgetTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(t.socialMediaCard.widgetSubtitle),
      ),
      expanded: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: const CustomCard(
          child: Column(
            children: <Widget>[
              SocialMediaItem(
                icon: FaIcon(FontAwesomeIcons.github),
                title: Text('GitHub'),
                subtitle: Text('github.com/LuisCupul04'),
                url: 'https://github.com/LuisCupul04',
              ),
            ],
          ),
        ),
      ),
      collapsed: const SizedBox(),
    );
  }
}
