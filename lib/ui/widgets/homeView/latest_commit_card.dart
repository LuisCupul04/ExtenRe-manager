/*
 * Copyright (C) 2022 ReVanced LLC
 * Copyright (C) 2022 inotia00
 * Copyright (C) 2026 LuisCupul04
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

import 'package:flutter/material.dart';
import 'package:extenre_manager/app/app.locator.dart';
import 'package:extenre_manager/gen/strings.g.dart';
import 'package:extenre_manager/ui/views/home/home_viewmodel.dart';
import 'package:extenre_manager/ui/widgets/shared/custom_card.dart';

class LatestCommitCard extends StatefulWidget {
  const LatestCommitCard({
    super.key,
    required this.model,
    required this.parentContext,
  });
  final HomeViewModel model;
  final BuildContext parentContext;

  @override
  State<LatestCommitCard> createState() => _LatestCommitCardState();
}

class _LatestCommitCardState extends State<LatestCommitCard> {
  final HomeViewModel model = locator<HomeViewModel>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // RVX Manager
        CustomCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('RVX Manager'),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        FutureBuilder<String?>(
                          future: model.getLatestManagerReleaseTime(),
                          builder: (context, snapshot) =>
                              snapshot.hasData && snapshot.data!.isNotEmpty
                                  ? Text(
                                      t.latestCommitCard
                                          .timeagoLabel(time: snapshot.data!),
                                    )
                                  : Text(t.latestCommitCard.loadingLabel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FutureBuilder<bool>(
                future: model.hasManagerUpdates(),
                initialData: false,
                builder: (context, snapshot) => FilledButton(
                  onPressed: () => widget.model.showUpdateConfirmationDialog(
                    widget.parentContext,
                    false,
                    !snapshot.data!,
                  ),
                  child: (snapshot.hasData && !snapshot.data!)
                      ? Text(t.showChangelogButton)
                      : Text(t.showUpdateButton),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Patches
        CustomCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('ExtenRe Patches'),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        FutureBuilder<String?>(
                          future: model.getLatestPatchesReleaseTime(),
                          builder: (context, snapshot) => Text(
                            snapshot.hasData && snapshot.data!.isNotEmpty
                                ? t.latestCommitCard
                                    .timeagoLabel(time: snapshot.data!)
                                : t.latestCommitCard.loadingLabel,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FutureBuilder<bool>(
                future: model.hasPatchesUpdates(),
                initialData: false,
                builder: (context, snapshot) => FilledButton(
                  onPressed: () => widget.model.showUpdateConfirmationDialog(
                    widget.parentContext,
                    true,
                    !snapshot.data!,
                  ),
                  child: (snapshot.hasData && !snapshot.data!)
                      ? Text(t.showChangelogButton)
                      : Text(t.showUpdateButton),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
