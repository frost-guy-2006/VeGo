import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vego/core/theme/app_colors.dart';

class CancelReasonDialog extends StatefulWidget {
  const CancelReasonDialog({super.key});

  @override
  State<CancelReasonDialog> createState() => _CancelReasonDialogState();
}

class _CancelReasonDialogState extends State<CancelReasonDialog> {
  String? _selectedReason;
  final _otherController = TextEditingController();

  static const _reasons = [
    'Changed my mind',
    'Found a better price',
    'Ordered by mistake',
    'Delivery taking too long',
    'Other',
  ];

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Cancel Order',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you cancelling?',
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
            ),
            const SizedBox(height: 12),
            RadioGroup<String>(
              groupValue: _selectedReason,
              onChanged: (v) => setState(() => _selectedReason = v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _reasons.map((r) => RadioListTile<String>(
                      title: Text(r, style: GoogleFonts.plusJakartaSans()),
                      value: r,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    )).toList(),
              ),
            ),
            if (_selectedReason == 'Other')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: _otherController,
                  decoration: InputDecoration(
                    hintText: 'Please specify...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Back',
            style: GoogleFonts.plusJakartaSans(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: _selectedReason == null
              ? null
              : () {
                  final reason = _selectedReason == 'Other'
                      ? _otherController.text.trim().isEmpty
                          ? 'Other'
                          : _otherController.text.trim()
                      : _selectedReason!;
                  Navigator.pop(context, reason);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.red.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Confirm Cancel',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
