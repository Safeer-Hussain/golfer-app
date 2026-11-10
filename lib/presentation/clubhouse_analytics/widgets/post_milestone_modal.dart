import 'package:flutter/material.dart';

import '../../../core/utils/app_feedback.dart';
import '../clubhouse_controller.dart';

class PostMilestoneModal extends StatefulWidget {
  final ClubhouseController controller;

  const PostMilestoneModal({super.key, required this.controller});

  @override
  State<PostMilestoneModal> createState() => _PostMilestoneModalState();
}

class _PostMilestoneModalState extends State<PostMilestoneModal> {
  final _formKey = GlobalKey<FormState>();
  final _courseController = TextEditingController(
    text: 'Lahore Garrison Golf & CC',
  );
  final _scoreController = TextEditingController(text: '71');
  final _diffController = TextEditingController(text: '-1');
  final _textController = TextEditingController();

  @override
  void dispose() {
    _courseController.dispose();
    _scoreController.dispose();
    _diffController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final gross = int.tryParse(_scoreController.text.trim());
      await widget.controller.createMilestonePost(
        courseName: _courseController.text.trim(),
        textContent: _textController.text.trim(),
        scoreGross: gross,
        scoreNet: gross != null ? gross - 4 : null,
        diffVsPar: _diffController.text.trim(),
        firPct: 72,
        girPct: 67,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      AppFeedback.showSuccess(
        context,
        'Milestone published to Clubhouse Feed.',
      );
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Post Round Milestone',
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
                const SizedBox(height: 14),
                TextFormField(
                  controller: _courseController,
                  decoration: InputDecoration(
                    labelText: 'Golf Course',
                    prefixIcon: const Icon(Icons.golf_course_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Course name cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _scoreController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Gross Score',
                          prefixIcon: const Icon(
                            Icons.format_list_numbered_rounded,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter score';
                          }
                          final num = int.tryParse(val.trim());
                          if (num == null || num < 50 || num > 160) {
                            return 'Invalid score';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _diffController,
                        decoration: InputDecoration(
                          labelText: 'vs Par',
                          hintText: 'e.g. -2, E, +4',
                          prefixIcon: const Icon(Icons.trending_down_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter vs Par';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _textController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Round Story / Milestone',
                    hintText: 'Share your round highlights, key shots, and course conditions...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter some round thoughts';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.publish_rounded, size: 18),
                  label: const Text(
                    'Publish Milestone',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
