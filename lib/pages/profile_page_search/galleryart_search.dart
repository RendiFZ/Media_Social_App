import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';


class GalleryArtSearch extends StatefulWidget {
  final String userId;

  GalleryArtSearch({required this.userId});

  @override
  _GalleryArtSearchState createState() => _GalleryArtSearchState();
}

class _GalleryArtSearchState extends State<GalleryArtSearch> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> imageUrls = [];
  List<firebase_storage.Reference> imageRefs = []; // Menyimpan referensi gambar

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

  Future<void> fetchImageUrls() async {
    String userId = widget.userId; // Gunakan userId dari widget
    firebase_storage.ListResult result =
        await firebase_storage.FirebaseStorage.instance.ref('posts_img/$userId').listAll();

    List<String> fetchedImageUrls = [];
    for (var ref in result.items) {
      String url = await ref.getDownloadURL();
      fetchedImageUrls.add(url);
      imageRefs.add(ref); // Menambahkan referensi ke list
    }

    setState(() {
      imageUrls = fetchedImageUrls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.0, // Membuat gambar berbentuk kotak
      mainAxisSpacing: 4.0, // Menambahkan spacing vertikal
      crossAxisSpacing: 4.0, // Menambahkan spacing horizontal
      children: List.generate(imageUrls.length, (index) {
        return Padding(
          padding: EdgeInsets.all(4.0), // Menambahkan padding di sekeliling gambar
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(imageUrls[index], fit: BoxFit.cover),
          ),
        );
      }),
    );
  }
}
