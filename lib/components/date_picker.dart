import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class InlineDatePickerField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const InlineDatePickerField({
    super.key,
    required this.hintText,
    required this.controller,
    this.validator,
  });

  @override
  State<InlineDatePickerField> createState() => _InlineDatePickerFieldState();
}

class _InlineDatePickerFieldState extends State<InlineDatePickerField> {
  bool showCalendar = false;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            //   suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
          ),
          onTap: () {
            setState(() => showCalendar = !showCalendar);
          },
          validator: widget.validator,
        ),

        if (showCalendar)
          Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime(1900),
              lastDay: DateTime.now(),
              focusedDay: selectedDate ?? DateTime.now(),
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                  widget.controller.text =
                      "${selectedDay.day}-${selectedDay.month}-${selectedDay.year}";
                  showCalendar = false; // hide calendar after selection
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
