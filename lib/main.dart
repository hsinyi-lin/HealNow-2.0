import 'package:flutter/material.dart';
import 'package:test_app/screen/home.dart';
import 'package:test_app/screen/main.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HealNow',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color.fromARGB(204, 12, 248, 228),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: const Myhome(),
      drawer: const AppDrawer(),
    );
  }
}
