import 'package:flutter/material.dart';

/// Material Date picker as a form field, keeping your UI layout unchanged.
/// Usage:
/// DateField(
///   label: 'Appointment Date',
///   firstDate: DateTime.now(),
///   lastDate: DateTime.now().add(const Duration(days: 365)),
///   initial: selectedDate,
///   onChanged: (d) => setState(() => selectedDate = d),
/// )
class DateField extends FormField<DateTime?> {
  DateField({
    Key? key,
    required String label,
    DateTime? initial,
    required DateTime firstDate,
    required DateTime lastDate,
    FormFieldSetter<DateTime?>? onSaved,
    FormFieldValidator<DateTime?>? validator,
    ValueChanged<DateTime?>? onChanged,
    String? helperText,
    bool enabled = true,
  }) : super(
    key: key,
    initialValue: initial,
    validator: validator,
    onSaved: onSaved,
    builder: (state) {
      final value = state.value;
      final display = value == null
          ? ''
          : MaterialLocalizations.of(state.context)
          .formatFullDate(value);

      Future<void> _pick() async {
        if (!enabled) return;
        final now = DateTime.now();
        final init = value ??
            DateTime(
              now.year,
              now.month,
              now.day,
            );
        final picked = await showDatePicker(
          context: state.context,
          initialDate: init,
          firstDate: firstDate,
          lastDate: lastDate,
          helpText: label,
        );
        if (picked != null) {
          state.didChange(picked);
          onChanged?.call(picked);
        }
      }

      return GestureDetector(
        onTap: _pick,
        child: InputDecorator(
          isEmpty: display.isEmpty,
          decoration: InputDecoration(
            labelText: label,
            helperText: helperText,
            errorText: state.errorText,
            enabled: enabled,
            suffixIcon: const Icon(Icons.calendar_today_rounded),
            border: const OutlineInputBorder(),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          child: Text(
            display.isEmpty ? 'Select date' : display,
            style: TextStyle(
              color: enabled ? null : Theme.of(state.context).disabledColor,
            ),
          ),
        ),
      );
    },
  );
}
