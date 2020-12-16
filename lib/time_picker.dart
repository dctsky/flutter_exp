import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class TimePicker extends StatelessWidget {
  final void Function(DateTime) onTimeChange;

  TimePicker({
    @required this.onTimeChange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: TimePickerSpinner(
        is24HourMode: true,
        normalTextStyle: TextStyle(
            fontSize: 20,
            color: Colors.black
        ),
        highlightedTextStyle: TextStyle(
            fontSize: 20,
            color: Colors.black
        ),
        spacing: 20,
        itemHeight: 50,
        isForce2Digits: true,
        onTimeChange: onTimeChange,
      ),
    );
  }
}
