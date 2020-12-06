import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatelessWidget {
  final void Function(DateTime) onDateTimeChanged;
  final String initDateStr;

  DatePicker({
    @required this.onDateTimeChanged,
    this.initDateStr,
  });

  @override
  Widget build(BuildContext context) {
    final initDate =
    DateFormat('yyyy-MM-dd').parse(initDateStr ?? '2021-01-01');
    return SizedBox(
      height: 150,
      child: CupertinoDatePicker(
        minimumYear: DateTime.now().year,
        maximumYear: 2100,
        initialDateTime: DateTime.now(),
        maximumDate: DateTime.utc(2100),
        onDateTimeChanged: onDateTimeChanged,
        mode: CupertinoDatePickerMode.date,
      ),
    );
  }
}