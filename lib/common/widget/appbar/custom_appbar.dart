import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget {
  CustomAppBar(
      {super.key,
      required this.title,
      required this.appBarOnPressed,
      this.hasBack = true,
      this.center = false,
      this.actions});
  String title;
  Function()? appBarOnPressed;
  List<Widget>? actions;
  bool? hasBack = true;
  bool? center = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: (center == false) ? false : true,
      leading: (hasBack == true)
          ? IconButton(
              onPressed: appBarOnPressed,
              icon: Icon(
                Icons.arrow_back,
                color: context.general.colorScheme.tertiary,
              ))
          : null,
      elevation: 0,
      title: Text(
        title,
        style: context.general.textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.bold, color: context.general.colorScheme.onPrimary),
      ),
      actions: actions,
    );
  }
}
