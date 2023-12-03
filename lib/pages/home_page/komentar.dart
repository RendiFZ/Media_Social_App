import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Komentar extends StatelessWidget {
  final DocumentSnapshot document;

  const Komentar({required this.document});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    List<String> comments = List<String>.from(data['comments'] ?? []);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KomentarPage(document: document),
          ),
        );
      },
      child: Row(
        children: <Widget>[
          const Icon(Icons.comment),
          const SizedBox(width: 4.0),
          Text('${comments.length}'),
        ],
      ),
    );
  }
}

class KomentarPage extends StatefulWidget {
  final DocumentSnapshot document;

  const KomentarPage({required this.document});

  @override
  _KomentarPageState createState() => _KomentarPageState();
}

class _KomentarPageState extends State<KomentarPage> {
  final _commentController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<String> _getProfileImageUrl(String userId) async {
    final ref = FirebaseStorage.instance.ref().child('profils/Profils_$userId.png');
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: widget.document.reference.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Add a comment...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (_commentController.text.isNotEmpty) {
                          final currentUser = _auth.currentUser;
                          if (currentUser != null) {
                            comments.add({
                              'userId': currentUser.uid,
                              'username': currentUser.displayName,
                              'comment': _commentController.text,
                              'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())
                            });
                            widget.document.reference.update({'comments': comments});
                            _commentController.clear();
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    DateTime timestamp = DateTime.parse(comments[index]['timestamp']);
String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(timestamp);

                    return FutureBuilder<String>(
                      future: _getProfileImageUrl(comments[index]['userId']),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(snapshot.data!),
                            ),
                            title: Text('${comments[index]['username']}: ${comments[index]['comment']}'),
                            subtitle: Text(formattedDate, style: const TextStyle(fontSize: 10.0)),
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
