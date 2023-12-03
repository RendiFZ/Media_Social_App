import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:intl/intl.dart';
import 'package:rendi_art/pages/home_page/posti_line.dart';
import 'package:rendi_art/akun_page/login.dart'; // Import LoginPage

class HomePage extends StatelessWidget {
  final _auth = FirebaseAuth.instance; // Ini adalah instance FirebaseAuth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Ini adalah instance FirebaseFirestore

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser; // Mendapatkan pengguna saat ini
    if (currentUser == null) {
      // Navigate to login page
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage())); // Ini adalah fungsi yang dipanggil saat pengguna saat ini adalah null
      return Container(); // Return an empty container
    }
    final currentUserId = currentUser.uid; // Mendapatkan id pengguna saat ini
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts') // Ini adalah koleksi 'posts' dari Firestore
          .orderBy('timestamp', descending: true) // Ini adalah fungsi yang mengurutkan posts berdasarkan timestamp
          .snapshots(), // Ini adalah fungsi yang mendapatkan snapshot dari koleksi 'posts'
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong'); // Ini adalah teks yang ditampilkan jika terjadi kesalahan
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Ini adalah indikator progres yang ditampilkan saat menunggu data
        }

        return ListView(
          children:
              snapshot.data!.docs.map<Widget>((DocumentSnapshot document) {
            return PostCard(document: document, currentUserId: currentUserId); // Ini adalah widget PostCard yang ditampilkan untuk setiap dokumen dalam snapshot
          }).toList(), // Ini adalah daftar widget PostCard
        );
      },
    );
  }
}
