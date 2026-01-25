import 'package:flutter/material.dart';
import 'package:freshflow/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class GranularTimelineWidget extends StatefulWidget {
  final String eta;
  final VoidCallback onCallRider;

  const GranularTimelineWidget({
    super.key,
    required this.eta,
    required this.onCallRider,
  });

  @override
  State<GranularTimelineWidget> createState() => _GranularTimelineWidgetState();
}

class _GranularTimelineWidgetState extends State<GranularTimelineWidget> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _startDemoTimeline();
  }

  void _startDemoTimeline() async {
    // Simulate steps: 0=Placed, 1=Packing, 2=Assigned, 3=OnWay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _currentStep = 1);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _currentStep = 2);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _currentStep = 3);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arriving in',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.secondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    widget.eta,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (_currentStep >= 2)
                GestureDetector(
                  onTap: widget.onCallRider,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Call Rider',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Granular Steps
          _buildStep(0, "Order Placed",
              isCompleted: _currentStep >= 0, isCurrent: _currentStep == 0),
          const SizedBox(height: 12),
          _buildStep(1, "Packing items",
              subtext: "2 mins",
              isCompleted: _currentStep >= 1,
              isCurrent: _currentStep == 1),
          const SizedBox(height: 12),
          _buildStep(2, "Rider Assigned",
              subtext: "Ramesh Kumar (4.8⭐)",
              isCompleted: _currentStep >= 2,
              isCurrent: _currentStep == 2),
          const SizedBox(height: 12),
          _buildStep(3, "On the Way",
              subtext: "Reaching your location",
              isCompleted: _currentStep >= 3,
              isCurrent: _currentStep == 3),
        ],
      ),
    );
  }

  Widget _buildStep(int stepIndex, String title,
      {String? subtext, required bool isCompleted, required bool isCurrent}) {
    Color color = isCompleted ? AppColors.primary : Colors.grey[300]!;
    if (isCurrent && _currentStep < 3)
      color = Colors.orange; // Highlight active processing step

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: isCompleted || isCurrent
                    ? FontWeight.bold
                    : FontWeight.normal,
                color:
                    isCompleted || isCurrent ? AppColors.textDark : Colors.grey,
              ),
            ),
            if (subtext != null && (isCompleted || isCurrent))
              Text(
                subtext,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
          ],
        )
      ],
    );
  }
}
