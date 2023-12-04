import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rendi_art/pages/profile_page_search/threadpost_search.dart';
import 'package:rendi_art/pages/selection/editprofil.dart';
import 'package:rendi_art/pages/selection/threadpost.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'galleryart_search.dart'; // Import file galleryart_search.dart

class ProfilPageSearch extends StatefulWidget {
  final String userId;

  ProfilPageSearch({required this.userId});

  @override
  _ProfilPageSearchState createState() => _ProfilPageSearchState();
}

class _ProfilPageSearchState extends State<ProfilPageSearch> {
  String? _profilePictureUrl;
  List<String> imageUrls = [];
  List<String> posts = [];

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
    fetchPosts();
    fetchProfilePicture();
  }

  Future<void> fetchImageUrls() async {
    String userId = widget.userId; // Gunakan userId dari widget
    firebase_storage.ListResult result =
        await firebase_storage.FirebaseStorage.instance.ref('posts_img/$userId').listAll();

    List<String> fetchedImageUrls = [];
    for (var ref in result.items) {
      String url = await ref.getDownloadURL();
      fetchedImageUrls.add(url);
    }

    setState(() {
      imageUrls = fetchedImageUrls;
    });
  }

  Future<void> fetchPosts() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('posts').get();
    List<String> fetchedPosts =
        querySnapshot.docs.map((doc) => doc['post'] as String).toList();
    setState(() {
      posts = fetchedPosts;
    });
  }

  Future fetchProfilePicture() async {
    String userId = widget.userId; // Gunakan userId dari widget
    String filePath = 'profils/Profils_$userId.png';
    try {
      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref(filePath)
          .getDownloadURL();
      setState(() {
        _profilePictureUrl = downloadURL;
      });
    } catch (e) {
      setState(() {
        _profilePictureUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Drei Art Thread'), // Ini adalah judul AppBar
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage()),
                        );
                      },
                      child: Stack(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 40.0,
                            backgroundImage: _profilePictureUrl != null
                                ? NetworkImage(_profilePictureUrl!)
                                : null,
                            child: _profilePictureUrl == null
                                ? const Icon(Icons.account_circle, size: 80.0)
                                : null,
                          ),
                          const Positioned(
                            right: 0,
                            bottom: 0,
                            child: Icon(Icons.edit, size: 20.0),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('profils')
                          .doc(widget.userId)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text("Something went wrong");
                        }
                        if (snapshot.hasData && !snapshot.data!.exists) {
                          return const Text("Document does not exist");
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, dynamic> data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          return Column(
                            children: <Widget>[
                              Text(
                                data['username'] ?? 'Anonymous', // Menampilkan username
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        '${data['allpost']?.length ?? 0}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Center(
                                          child: Text(
                                              'Posts')), // Memusatkan teks 'Posts'
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        '${data['followers']?.length ?? 0}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Center(
                                          child: Text(
                                              'Followers')), // Memusatkan teks 'Followers'
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        '${data['following']?.length ?? 0}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Center(
                                          child: Text(
                                              'Following')), // Memusatkan teks 'Following'
                                    ],
                                  ),
                                ],
                              ),
                              Text(data['bio'] ?? ''), // Menampilkan bio
                            ],
                          );
                        }
                        return const CircularProgressIndicator(); // Show a loading spinner while waiting for data
                      },
                    ),
                  ],
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'Showcase'),
                  Tab(text: 'Thread'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    GalleryArtSearch(userId: widget.userId), // Pass userId to GalleryArt
                    ThreadPostSearch(userId: widget.userId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
