// datetime_range_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeRangeSection extends StatelessWidget {
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final String startTimeText;
  final String endTimeText;
  final VoidCallback onPickDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;

  const DateTimeRangeSection({
    super.key,
    required this.startDateController,
    required this.endDateController,
    required this.startTimeText,
    required this.endTimeText,
    required this.onPickDate,
    required this.onPickStartTime,
    required this.onPickEndTime,
  });

  Widget _buildSectionHeader(IconData icon, String title, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledField(TextEditingController controller) {
    return Expanded(
      child: TextFormField(
        enabled: false,
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildTimeButton(String label, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E4D92)),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(Icons.calendar_month, 'Tarikh & Masa', Colors.teal),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildDisabledField(startDateController),
            const SizedBox(width: 10),
            _buildDisabledField(endDateController),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPickDate,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E4D92)),
            child: const Text('Pilih Tarikh', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildTimeButton(startTimeText, onPickStartTime),
            const SizedBox(width: 10),
            _buildTimeButton(endTimeText, onPickEndTime),
          ],
        ),
      ],
    );
  }
}
