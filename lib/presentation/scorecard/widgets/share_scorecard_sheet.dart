import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/app_feedback.dart';
import '../scorecard_controller.dart';

class ShareScorecardSheet extends StatefulWidget {
  final ScorecardController controller;

  const ShareScorecardSheet({super.key, required this.controller});

  @override
  State<ShareScorecardSheet> createState() => _ShareScorecardSheetState();
}

class _ShareScorecardSheetState extends State<ShareScorecardSheet> {
  final _commentController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handlePostToClubhouse() async {
    setState(() => _isPosting = true);
    try {
      await widget.controller.postRoundToClubhouse(
        commentary: _commentController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      AppFeedback.showSuccess(
        context,
        'Round posted to Clubhouse Social Feed.',
      );
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  Future<void> _handleCopyAscii() async {
    await widget.controller.copyAsciiScorecardToClipboard();
    if (!mounted) return;
    Navigator.of(context).pop();
    AppFeedback.showSuccess(context, 'ASCII Scorecard copied to clipboard.');
  }

  Future<void> _handleExportTelemetry() async {
    final jsonStr = const JsonEncoder.withIndent('  ')
        .convert(widget.controller.activeScorecard.toJson());
    await Clipboard.setData(ClipboardData(text: jsonStr));
    if (!mounted) return;
    Navigator.of(context).pop();
    AppFeedback.showSuccess(
      context,
      'Round Telemetry JSON copied to clipboard.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Share Round Scorecard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Round Notes / Highlights',
                  hintText: 'e.g. 4 birdies on back 9, driver carried 280 yds consistently!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isPosting ? null : _handlePostToClubhouse,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Post to Clubhouse Feed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _handleCopyAscii,
                icon: const Icon(Icons.content_copy_rounded, size: 18),
                label: const Text('Copy Formatted ASCII Scorecard'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(color: colorScheme.outlineVariant),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _handleExportTelemetry,
                icon: const Icon(Icons.data_object_rounded, size: 18),
                label: const Text('Export Round Telemetry (JSON)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.secondary,
                  side: BorderSide(
                    color: colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
