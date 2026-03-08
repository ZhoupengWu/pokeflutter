import 'package:flutter/material.dart';

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
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 76, left: 24, right: 24),
            child: Text("Pokédex")),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text("Use the advanced search to find Pokémon by type, weakness, ability and more!"))
        ],
      ),
    );
  }
}