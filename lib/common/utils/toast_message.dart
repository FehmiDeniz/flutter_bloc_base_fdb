import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showSuccessMessage(BuildContext context, String? message) {
  Fluttertoast.showToast(
    msg: message ?? 'İşlem Başarılı',
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: Colors.green,
    textColor: Theme.of(context).colorScheme.onPrimary,
    fontSize: 16.0,
  );
}

void showErrorLoginMessage(BuildContext context, String? message) {
  Fluttertoast.showToast(
    msg: message ?? 'Giriş işlemi başarısız. Lütfen bilgilerinizi kontrol edip tekrar deneyin.',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: Theme.of(context).colorScheme.error,
    textColor: Theme.of(context).colorScheme.onError,
    fontSize: 16.0,
  );
}

void showErrorMessage(BuildContext context, String? message) {
  Fluttertoast.showToast(
    msg: message ?? 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: Theme.of(context).colorScheme.error,
    textColor: Theme.of(context).colorScheme.onError,
    fontSize: 16.0,
  );
}
