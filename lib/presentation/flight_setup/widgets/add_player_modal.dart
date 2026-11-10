import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_feedback.dart';

class AddPlayerModal extends StatefulWidget {
  final Function({
    required String name,
    required double handicap,
    required String teeBox,
  })
  onAddPlayer;

  const AddPlayerModal({super.key, required this.onAddPlayer});

  @override
  State<AddPlayerModal> createState() => _AddPlayerModalState();
}

class _AddPlayerModalState extends State<AddPlayerModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _handicapController = TextEditingController();
  String _selectedTee = AppConstants.teeBlack;

  @override
  void dispose() {
    _nameController.dispose();
    _handicapController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final hcp = double.parse(_handicapController.text.trim());

      widget.onAddPlayer(name: name, handicap: hcp, teeBox: _selectedTee);

      Navigator.of(context).pop();
      AppFeedback.showSuccess(context, '$name added to active flight.');
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                      'Add Custom Player',
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Player Name',
                    hintText: 'e.g. Tariq Mehmood',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a valid player name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _handicapController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Handicap Index',
                    hintText: '0.0 to 54.0',
                    prefixIcon: const Icon(Icons.trending_up_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter handicap index (e.g. 12.4)';
                    }
                    final hcp = double.tryParse(value.trim());
                    if (hcp == null || hcp < 0.0 || hcp > 54.0) {
                      return 'Handicap must be a number between 0.0 and 54.0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTee,
                  decoration: InputDecoration(
                    labelText: 'Assigned Tee Box',
                    prefixIcon: const Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AppConstants.teeBlack,
                      child: Text(AppConstants.teeBlack),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.teeBlue,
                      child: Text(AppConstants.teeBlue),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.teeWhite,
                      child: Text(AppConstants.teeWhite),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.teeRed,
                      child: Text(AppConstants.teeRed),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedTee = val);
                    }
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add to Flight',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
