import 'package:flutter/material.dart';
import 'package:rendi_art/akun_page/login.dart';
import 'package:rendi_art/ui/navbar_ui.dart';
import 'package:rendi_art/auth.dart'; // Ganti dengan path AuthService Anda
import 'package:firebase_core/firebase_core.dart';


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
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Tampilkan loading spinner saat menunggu
          } else {
            if (snapshot.data ?? false) {
              return MyNavBar(); // Jika pengguna sudah login, arahkan ke homepage
            } else {
              return LoginPage(); // Jika pengguna belum login, arahkan ke halaman login
            }
          }
        },
      ),
    );
  }
}
