import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rendi_art/pages/profile_page_search/ThreadPostCard_Search.dart';


class ThreadPostSearch extends StatelessWidget {
  final String userId;

  ThreadPostSearch({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Text('Tidak ada postingan');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return ThreadPostCardSearch(document: snapshot.data!.docs[index], currentUserId: userId,);
            },
          );
        }
      },
    );
  }
}
