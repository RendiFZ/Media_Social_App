import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PostingPage extends StatefulWidget {
  @override
  _PostingPageState createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
  // ignore: unused_field
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<File?> _imageFiles = [];

  Future<void> pickImage() async {
    if (_imageFiles.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maksimal 4 foto dapat diunggah')),
      );
      return;
    }
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var result = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        "${pickedFile.path}_compressed.jpg",
        quality: 88,
        minWidth: 600,
        minHeight: 600,
      );

      setState(() {
        if (result != null) {
          _imageFiles.add(result);
        } else {
          print('No image selected.');
        }
      });
    }
  }

Future<List<String>> uploadImages() async {
  User? user = FirebaseAuth.instance.currentUser;
  List<String> imageUrls = [];
  for (var imageFile in _imageFiles) {
    if (user != null && imageFile != null) {
      final ref = _storage
          .ref()
          .child('posts_img') // Mengubah ini menjadi 'posts_img'
          .child(user.uid) // Menambahkan folder untuk setiap pengguna
          .child('${DateTime.now()}.jpg'); // Menghapus user.uid dari nama file
      await ref.putFile(imageFile);
      imageUrls.add(await ref.getDownloadURL());
    }
  }
  return imageUrls;
}

void sendText() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    List<String> imageUrls = await uploadImages();
    DocumentReference postRef = await _firestore
        .collection('posts')
        .add({
      'userId': user.uid,
      'username': user.displayName,
      'caption': _captionController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'imageUrls': imageUrls,
      'loveCount': 0, // Menambahkan field 'loveCount' dengan nilai awal 0
    });

    // Mendapatkan referensi ke dokumen profil pengguna
    DocumentReference profileRef = _firestore.collection('profils').doc(user.uid);

    // Menambahkan ID postingan baru ke array 'allpost'
    profileRef.update({
      'allpost': FieldValue.arrayUnion([postRef.id])
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Postingan berhasil dikirim')),
    );
    _captionController.clear();
    setState(() {
      _imageFiles.clear();
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Postingan gagal terkirim')),
    );
  }
}

  Future<String> getProfilePictureUrl() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String filePath = 'profils/Profils_$userId.png';
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(filePath)
        .getDownloadURL();
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('New Post'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: sendText,
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          FutureBuilder<String>(
            future: getProfilePictureUrl(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError || snapshot.data == null) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.account_circle),
                    radius: 25,
                  ),
                  title: Text(user?.displayName ?? 'Anonymous'),
                );
              } else {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(snapshot.data!),
                    radius: 25,
                  ),
                  title: Text(user?.displayName ?? 'Anonymous'),
                );
              }
            },
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  Icons.add_a_photo,
                  color: Color.fromARGB(255, 173, 173, 173),
                  size: 35,
                ),
                onPressed: pickImage,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _captionController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Write a caption...',
              ),
            ),
          ),
          // Tambahkan widget ini untuk menampilkan gambar
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            children: List.generate(_imageFiles.length, (index) {
              return Center(
                child: Image.file(
                  _imageFiles[index]!,
                  fit: BoxFit.cover,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
