import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

// ignore: must_be_immutable
class CustomCheckBox extends StatelessWidget {
  CustomCheckBox({super.key, required this.value, required this.onChanged, required this.title});
  bool value;
  String title;
  Function(bool? value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      checkColor: context.general.colorScheme.onInverseSurface,
      checkboxShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      activeColor: context.general.colorScheme.primary,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: context.general.textTheme.labelMedium
            ?.copyWith(color: context.general.colorScheme.onPrimary, fontWeight: FontWeight.w500),
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    );
  }
}
