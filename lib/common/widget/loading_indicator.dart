import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';
import 'package:loading_indicator/loading_indicator.dart';

void showLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.white.withValues(alpha: 0.5),
    builder: (context) {
      return const Center(child: AppLoadingIndicator());
    },
  );
}

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: LoadingIndicator(
        indicatorType: Indicator.ballClipRotateMultiple,
        colors: [context.general.colorScheme.primary],
        strokeWidth: 3,
        backgroundColor: Colors.transparent,
        pathBackgroundColor: Colors.transparent,
      ),
    );
  }
}
