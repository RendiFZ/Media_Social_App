import 'package:flutter/material.dart';
import 'package:rendi_art/akun_page/login.dart';
import 'package:rendi_art/ui/navbar_ui.dart';
import 'package:rendi_art/auth.dart'; // Ganti dengan path AuthService Anda
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        hintColor: Colors.cyanAccent,
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.white70),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.cyanAccent),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.cyanAccent),
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.cyanAccent,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return snapshot.data != null ? MyNavBar() : LoginPage();
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

