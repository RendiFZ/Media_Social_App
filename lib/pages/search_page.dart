import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rendi_art/pages/profil_page.dart';
import 'package:rendi_art/pages/profile_page_search/profile_page_search.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> searchUsers(String query) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('profils')
        .where('username', isGreaterThanOrEqualTo: query)
        .limit(10)
        .get();
    List<Map<String, dynamic>> searchResults = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String imageUrl = '';
      try {
        imageUrl = await firebase_storage.FirebaseStorage.instance
            .ref('profils/Profils_${doc.id}.png')
            .getDownloadURL();
      } catch (e) {
        // handle error
      }
      searchResults.add({
        'username': data['username'] as String,
        'imageUrl': imageUrl,
        'userId': doc.id,
      });
    }
    setState(() {
      _searchResults = searchResults;
    });
  }

  Future<void> followUser(String userId) async {
    // TODO: Replace 'currentUserId' with the ID of the current user
    String currentUserId =
        FirebaseAuth.instance.currentUser!.uid; // get current user id
    DocumentReference currentUserDocRef =
        _firestore.collection('profils').doc(currentUserId);
    DocumentReference userDocRef = _firestore.collection('profils').doc(userId);

    DocumentSnapshot currentUserDocSnapshot = await currentUserDocRef.get();
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    if (!currentUserDocSnapshot.exists || !userDocSnapshot.exists) {
      print("User document does not exist");
      return;
    }

    Map<String, dynamic> currentUserData =
        currentUserDocSnapshot.data() as Map<String, dynamic>;
    Map<String, dynamic> userData =
        userDocSnapshot.data() as Map<String, dynamic>;

    if (!currentUserData.containsKey('following')) {
      await currentUserDocRef.update({
        'following': [],
      });
    }
    if (!userData.containsKey('followers')) {
      await userDocRef.update({
        'followers': [],
      });
    }

    await currentUserDocRef.update({
      'following': FieldValue.arrayUnion([userId]),
    });
    await userDocRef.update({
      'followers': FieldValue.arrayUnion([currentUserId]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                searchUsers(_searchController.text);
              },
            ),
          ],
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilPageSearch(
                        userId: _searchResults[index]['userId']),
                  ),
                );
              },
              child: ListTile(
                leading: _searchResults[index]['imageUrl'] != ''
                    ? CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            NetworkImage(_searchResults[index]['imageUrl']),
                      )
                    : CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.account_circle, size: 60),
                      ),
                title: Text(_searchResults[index]['username']),
                trailing: ElevatedButton(
                  child: Text('Follow'),
                  onPressed: () {
                    followUser(_searchResults[index]['userId']);
                  },
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
