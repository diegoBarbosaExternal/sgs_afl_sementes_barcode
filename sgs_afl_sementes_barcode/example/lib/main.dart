import 'package:barcode_scan_example/LoginScreen.dart';
import 'package:barcode_scan_example/Scanner.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",      // Nomeando rotas
      routes: {
        "/scanner":(context) => Scanner()
      },

      home: LoginScreen(),
    )
  );
}

