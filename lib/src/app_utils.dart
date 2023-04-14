import 'package:flutter/material.dart';

class AppConstants {
  static const appGreyColor = Colors.grey;

  static const boxRadiusAll12 = BorderRadius.all(Radius.circular(12));

  static var boxBorderDecorationPrimary = BoxDecoration(
      border: Border.all(color: appGreyColor),
      borderRadius: boxRadiusAll12,
      color: Colors.orange[600]);
      static var boxBorderDecoration = BoxDecoration(
      border: Border.all(color: Colors.grey), borderRadius: boxRadiusAll12);


      static void showSnackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(
        content: Text(msg, style: Theme.of(context).textTheme.bodySmall),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static InputDecoration inputDecorationValidate(
      BuildContext context, String hint) {
    return InputDecoration(
        // contentPadding: AppConstants.all_5,
        fillColor: Colors.transparent,
        filled: true,
        counterStyle: Theme.of(context).textTheme.bodySmall,
        counterText: "",
        hintText: hint,
        errorStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w400, color: Colors.red),
        hintStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusColor: Colors.grey,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ));
  }
}
