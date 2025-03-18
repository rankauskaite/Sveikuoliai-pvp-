import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, bool success) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    ),
    backgroundColor: success
        ? const Color(0x8066E600) // Šviesesnė, ryškesnė žalia su permatomumu
        : const Color(0x80FF3D3D), // Šviesesnė raudona su permatomumu
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0), // Viršutinis kairysis kampas
        topRight: Radius.circular(16.0), // Viršutinis dešinysis kampas
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
