import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Page'),
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your username';
                      }
                      // Regex untuk memeriksa apakah username hanya berisi huruf A-Z, angka 0-9, dan simbol "_"
                      bool isValid =
                          RegExp(r'^[A-Za-z0-9_]+$').hasMatch(value!);
                      if (!isValid) {
                        return 'Username can only contain letters A-Z, numbers 0-9, and the "_" symbol';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Password does not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );

                          User? user = userCredential.user;
                          if (user != null) {
                            await user.updateProfile(
                                displayName: _usernameController.text);
                            await user.reload();
                            user = _auth.currentUser;

                            await _firestore
                                .collection(
                                    'profils') // Mengubah 'Account' menjadi 'profils'
                                .doc(user
                                    ?.uid) // Menggunakan id pengguna sebagai document ID
                                .set({
                              'userId': user?.uid, // Menambahkan id pengguna
                              'username': _usernameController.text,
                              'email': _emailController.text,
                              'createdDate': DateTime.now()
                                  .toIso8601String(), // Menambahkan tanggal pembuatan
                              'firstLogin':
                                  true, // Menandai bahwa ini adalah login pertama
                              'following':
                                  [], // Menambahkan array kosong untuk 'following'
                              'followers':
                                  [], // Menambahkan array kosong untuk 'followers'
                              'allpost':
                                  [], // Menambahkan array kosong untuk 'allpost'
                            });

                            print(
                                "Pendaftaran berhasil dengan username: ${user?.displayName}, email: ${user?.email}");
                          }
// Mengirimkan data ke Firestore

                          if (user != null) {
                            print(
                                "Pendaftaran berhasil dengan email: ${user.email}");
                            // Tampilkan pop-up

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Pendaftaran Berhasil')),
                            );
                          } else {
                            print("Pendaftaran gagal.");
                            // Tampilkan pop-up
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Pendaftaran Gagal')),
                            );
                          }
                        } catch (e) {
                          print("Error: $e");
                          // Tampilkan pop-up
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Pendaftaran Gagal')),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    child: Text('Register'),
                  )
                ],
              ),
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
