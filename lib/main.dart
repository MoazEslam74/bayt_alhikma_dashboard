import 'package:bayt_alhikma_dashboard/screens/opening_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bayt Alhikma Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OpeningPage(),
    );
  }
}