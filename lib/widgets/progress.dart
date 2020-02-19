import 'package:flutter/material.dart';

Widget circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 10),
    child: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
    ),
  );
}

Widget linearProgress() {
  return Container(
    padding: const EdgeInsets.only(bottom: 10),
    child: const LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
    ),
  );
}
