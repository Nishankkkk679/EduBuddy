import 'package:firebase_core/firebase_core.dart';
import 'package:edubuddy/auth/screens/signin_screen.dart';
import 'package:flutter/material.dart';
//import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBYVVqx_rX7r7EebZvbB7FEDlEgODsSRuo',
      appId: 'com.example.edubuddy',
      messagingSenderId: '430758094341',
      projectId: 'edubuddy-5d1a0',
      authDomain: 'edubuddy-5d1a0.firebaseapp.com',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduBuddy',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: const SignInScreen(),
    );
  }
}
