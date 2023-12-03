import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rendi_art/pages/selection/threadpostcard.dart';

class ThreadPost extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Text('Pengguna tidak ditemukan');
    }
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('profils').doc(userId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Text('Tidak ada postingan');
        } else {
          List<String> postIds = List<String>.from(snapshot.data!.get('allpost'));
          return ListView.builder(
            itemCount: postIds.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('posts').doc(postIds[index]).get(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                    return Text('Postingan tidak ditemukan');
                  } else {
                    // Menggunakan PostCard untuk menampilkan postingan
                    return PostCard(document: snapshot.data!, currentUserId: userId);
                  }
                },
              );
            },
          );
        }
      },
    );
  }
}
