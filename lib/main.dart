import 'package:flutter/material.dart';
import 'home_page.dart';
import 'main_screen.dart';  // Nếu bạn tách component như trên

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}