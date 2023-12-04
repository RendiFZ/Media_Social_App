import 'package:rendi_art/akun_page/register.dart';
import 'package:flutter/material.dart';
import 'package:rendi_art/pages/home_page/home_page.dart';
import 'package:rendi_art/pages/selection/editprofil.dart';
import 'package:rendi_art/ui/navbar_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        hintColor: Colors.cyanAccent,
        textTheme: const TextTheme(
          bodyText2: const TextStyle(color: Colors.white70),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.cyanAccent),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.cyanAccent),
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.cyanAccent,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(' '),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16.0, 40.0, 16.0, 16.0),
              child: ListView(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                10),
                            child: Image.asset(
                                'packages/rendi_art/assets/img/logo/Luxqo Drei.png'),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: 'Username'),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  UserCredential userCredential = await FirebaseAuth
                                      .instance
                                      .signInWithEmailAndPassword(
                                    email: _usernameController.text,
                                    password: _passwordController.text,
                                  );
                                  User? user = userCredential.user;
                                  if (user != null) {
                                    DocumentSnapshot userProfileSnapshot =
                                        await FirebaseFirestore.instance
                                            .collection('profils')
                                            .doc(user.uid)
                                            .get();

                                    if (userProfileSnapshot.exists) {
                                      Map<String, dynamic> data =
                                          userProfileSnapshot.data()
                                              as Map<String, dynamic>;
                                      if (data['firstLogin'] == true) {
                                        await FirebaseFirestore.instance
                                            .collection('profils')
                                            .doc(user.uid)
                                            .update({'firstLogin': false});

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfilePage()),
                                        );
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MyNavBar()),
                                        );
                                      }
                                    }
                                  }
                                } on FirebaseAuthException catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Error'),
                                        content: Text('Terjadi kesalahan, Email atau Password tidak sesuai'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                            child: Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 275.0),
                        RichText(
                          text: TextSpan(
                            text: 'Belum punya akun? ',
                            style: const TextStyle(fontSize: 14),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Daftar Disini',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    fontSize: 14),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RegisterPage()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const ModalBarrier(dismissible: false, color: Colors.black45),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
