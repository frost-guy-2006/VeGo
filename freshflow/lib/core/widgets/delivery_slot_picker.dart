import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class DeliverySlot {
  final DateTime date;
  final String timeLabel;

  const DeliverySlot({required this.date, required this.timeLabel});

  String get displayText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    String dayText;
    if (date == today) {
      dayText = 'Today';
    } else if (date == today.add(const Duration(days: 1))) {
      dayText = 'Tomorrow';
    } else {
      dayText = DateFormat('EEE, MMM d').format(date);
    }
    return '$dayText, $timeLabel';
  }
}

/// Shows a bottom sheet for picking a delivery slot.
Future<DeliverySlot?> showDeliverySlotPicker(BuildContext context) {
  return showModalBottomSheet<DeliverySlot>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DeliverySlotSheet(),
  );
}

class _DeliverySlotSheet extends StatefulWidget {
  const _DeliverySlotSheet();

  @override
  State<_DeliverySlotSheet> createState() => _DeliverySlotSheetState();
}

class _DeliverySlotSheetState extends State<_DeliverySlotSheet> {
  int _selectedDay = 0;
  int _selectedSlot = -1;

  List<DateTime> get _days {
    final now = DateTime.now();
    return List.generate(5, (i) => DateTime(now.year, now.month, now.day + i));
  }

  static const _timeSlots = [
    '7:00 AM - 9:00 AM',
    '9:00 AM - 11:00 AM',
    '11:00 AM - 1:00 PM',
    '2:00 PM - 4:00 PM',
    '4:00 PM - 6:00 PM',
    '6:00 PM - 8:00 PM',
  ];

  bool _isSlotAvailable(int dayIdx, int slotIdx) {
    if (dayIdx > 0) return true;
    final hour = slotIdx < 3 ? 7 + slotIdx * 2 : 14 + (slotIdx - 3) * 2;
    return DateTime.now().hour < hour;
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: context.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Schedule Delivery',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20, fontWeight: FontWeight.bold,
              color: context.textPrimary)),
          const SizedBox(height: 16),
          _buildDaySelector(days),
          const SizedBox(height: 20),
          Text('Available Slots',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: context.textPrimary)),
          const SizedBox(height: 12),
          _buildTimeSlots(),
          const SizedBox(height: 24),
          _buildConfirmButton(days),
        ],
      ),
    );
  }

  Widget _buildDaySelector(List<DateTime> days) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final d = days[i];
          final sel = _selectedDay == i;
          final label = i == 0 ? 'Today' : i == 1 ? 'Tmrw' : DateFormat('EEE').format(d);
          return GestureDetector(
            onTap: () => setState(() { _selectedDay = i; _selectedSlot = -1; }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : context.surfaceAltColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? AppColors.primary : context.borderColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : context.textSecondary)),
                  const SizedBox(height: 4),
                  Text(DateFormat('d').format(d), style: GoogleFonts.plusJakartaSans(
                    fontSize: 20, fontWeight: FontWeight.bold,
                    color: sel ? Colors.white : context.textPrimary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: List.generate(_timeSlots.length, (i) {
        final avail = _isSlotAvailable(_selectedDay, i);
        final sel = _selectedSlot == i;
        return GestureDetector(
          onTap: avail ? () => setState(() => _selectedSlot = i) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: !avail
                  ? context.surfaceAltColor.withValues(alpha: 0.5)
                  : sel ? AppColors.primary : context.surfaceAltColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: sel ? AppColors.primary : context.borderColor.withValues(alpha: 0.3)),
            ),
            child: Text(_timeSlots[i], style: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: !avail
                  ? context.textSecondary.withValues(alpha: 0.4)
                  : sel ? Colors.white : context.textPrimary)),
          ),
        );
      }),
    );
  }

  Widget _buildConfirmButton(List<DateTime> days) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        onPressed: _selectedSlot >= 0
            ? () => Navigator.pop(context, DeliverySlot(
                date: days[_selectedDay], timeLabel: _timeSlots[_selectedSlot]))
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text('Confirm Slot', style: GoogleFonts.plusJakartaSans(
          fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
