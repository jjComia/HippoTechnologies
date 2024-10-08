import 'package:flutter/material.dart';

void showSlidingGeneralDialog({
  required BuildContext context,
  required WidgetBuilder pageBuilder,
  Duration transitionDuration = const Duration(milliseconds: 300),
  Color barrierColor = Colors.black54,
  bool barrierDismissible = true,
  String barrierLabel = '',
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    pageBuilder: (context, anim1, anim2) => pageBuilder(context),
    transitionBuilder: (context, anim1, anim2, child) {
      final curvedAnimation = CurvedAnimation(parent: anim1, curve: Curves.easeInOut);
      return SlideTransition(
        position: Tween<Offset>(begin: Offset(1, 0), end: Offset.zero).animate(curvedAnimation),
        child: child,
      );
    },
  );
}