import 'package:flutter/material.dart';
import 'views/homepage.dart';
import 'utils/palette.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: gray,
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: gray[500],
          unselectedItemColor: gray[300],
          backgroundColor: Colors.white
        )
      ),
      home: const HomePage(),
    );
  }
}