import 'package:flutter/material.dart';

/// Custom bottom sheet time picker with iOS-style wheel scrolling,
/// matching the app's dark theme.
///
/// Usage:
/// ```dart
/// final picked = await ReminderTimePicker.show(
///   context,
///   initialTime: TimeOfDay.now(),
/// );
/// if (picked != null) {
///   setState(() => _selectedTime = picked);
/// }
/// ```
class ReminderTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;

  const ReminderTimePicker({super.key, required this.initialTime});

  static Future<TimeOfDay?> show(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          ReminderTimePicker(initialTime: initialTime ?? TimeOfDay.now()),
    );
  }

  @override
  State<ReminderTimePicker> createState() => _ReminderTimePickerState();
}

class _ReminderTimePickerState extends State<ReminderTimePicker> {
  late int hour12; // 1-12
  late int minute; // 0-59
  late bool isPM;

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  // Colors pulled from the approved mockup
  static const Color bgColor = Color(0xFF14121F);
  static const Color pillBg = Color(0xFF1F1C2E);
  static const Color dimText = Color(0xFF4A4664);
  static const Color highlightBg = Color(0x1F7F77DD); // rgba(127,119,221,0.12)
  static const Color accentPurple = Color(0xFF7F77DD);
  static const Color amberPM = Color(0xFFFAC775);
  static const Color amberText = Color(0xFF412402);
  static const Color borderColor = Color(0xFF3A3750);
  static const Color secondaryText = Color(0xFF8B87A3);
  static const Color brightText = Color(0xFFEEEDFE);

  @override
  void initState() {
    super.initState();
    final t = widget.initialTime;
    isPM = t.period == DayPeriod.pm;
    hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    minute = t.minute;
    hourController = FixedExtentScrollController(initialItem: hour12 - 1);
    minuteController = FixedExtentScrollController(initialItem: minute);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  TimeOfDay get _resultTime {
    int hour24;
    if (isPM) {
      hour24 = hour12 == 12 ? 12 : hour12 + 12;
    } else {
      hour24 = hour12 == 12 ? 0 : hour12;
    }
    return TimeOfDay(hour: hour24, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Set reminder time',
                  style: TextStyle(color: secondaryText, fontSize: 13),
                ),
                _buildAmPmToggle(),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: highlightBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWheel(
                        controller: hourController,
                        itemCount: 12,
                        displayBuilder: (i) => (i + 1).toString(),
                        onChanged: (i) => setState(() => hour12 = i + 1),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          ':',
                          style: TextStyle(color: brightText, fontSize: 32),
                        ),
                      ),
                      _buildWheel(
                        controller: minuteController,
                        itemCount: 60,
                        displayBuilder: (i) => i.toString().padLeft(2, '0'),
                        onChanged: (i) => setState(() => minute = i),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: borderColor, width: 0.5),
                      foregroundColor: secondaryText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_resultTime),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentPurple,
                      foregroundColor: bgColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmPmToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_amPmOption('AM', !isPM), _amPmOption('PM', isPM)],
      ),
    );
  }

  Widget _amPmOption(String label, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => isPM = label == 'PM'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? amberPM : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? amberText : secondaryText,
            fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// A single scrollable wheel column (hour or minute).
  /// The item closest to the center gets full brightness and size;
  /// items further away fade out and shrink, mimicking the mockup.
  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) displayBuilder,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: 70,
      height: 170,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40,
        perspective: 0.003,
        diameterRatio: 1.4,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final double selected = controller.hasClients
                    ? controller.selectedItem.toDouble()
                    : index.toDouble();
                final double distance = (selected - index).abs().clamp(0, 2);
                final color =
                    Color.lerp(brightText, dimText, distance / 2) ?? brightText;
                final size = 32.0 - (distance * 7);
                final weight = distance < 0.5
                    ? FontWeight.w500
                    : FontWeight.normal;
                return Center(
                  child: Text(
                    displayBuilder(index),
                    style: TextStyle(
                      color: color,
                      fontSize: size,
                      fontWeight: weight,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
