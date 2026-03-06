import 'package:flutter/material.dart';
import 'package:speakdine_app/core/theme/color_ext.dart';

class TimePickerWidget extends StatefulWidget {
  final String label;
  final String selectedTime;
  final Function(String) onTimeSelected;

  const TimePickerWidget({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _time = _parseTime(widget.selectedTime);
  }

  @override
  void didUpdateWidget(TimePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTime != oldWidget.selectedTime) {
      _time = _parseTime(widget.selectedTime);
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      // Expected format "10:00 AM"
      final parts = timeStr.trim().split(" ");
      final timeParts = parts[0].split(":");
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      final period = parts.length > 1 ? parts[1] : "AM";

      if (period == "PM" && hour != 12) {
        hour += 12;
      } else if (period == "AM" && hour == 12) {
        hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0); // Default fallback
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorExt.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
      // Format back to string
      final localizations = MaterialLocalizations.of(context);
      final formattedTime = localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: false);
      widget.onTimeSelected(formattedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: colorExt.textField,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 20, color: colorExt.secondaryText),
            const SizedBox(width: 10),
            Text(
              widget.selectedTime.isEmpty ? _time.format(context) : widget.selectedTime,
              style: TextStyle(
                color: colorExt.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
