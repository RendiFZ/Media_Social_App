import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GalleryArt extends StatefulWidget {
  @override
  _GalleryArtState createState() => _GalleryArtState();
}

class _GalleryArtState extends State<GalleryArt> {
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> imageUrls = [];
  List<Reference> imageRefs = []; // Menyimpan referensi gambar

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

  Future<void> fetchImageUrls() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    ListResult result =
        await FirebaseStorage.instance.ref('posts_img/$userId').listAll();

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

  Future<void> deleteImage(int index) async {
    await imageRefs[index].delete(); // Menghapus gambar dari storage
    setState(() {
      imageUrls.removeAt(index); // Menghapus URL dari list
      imageRefs.removeAt(index); // Menghapus referensi dari list
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
        child: GestureDetector(
          onTap: () async {
            showModalBottomSheet(
              context: context,
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.file_download),
                    title: Text('Download Gambar'),
                    onTap: () {
                      // Implementasikan logika download gambar di sini
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Hapus Gambar'),
                    onTap: () async {
                      bool? shouldDelete = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Hapus Gambar'),
                          content: Text('Apakah Anda yakin ingin menghapus gambar ini?'),
                          actions: [
                            TextButton(
                              child: Text('Batal'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: Text('Hapus'),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        ),
                      );
                      if (shouldDelete == true) {
                        deleteImage(index);
                      }
                    },
                  ),
                ],
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(imageUrls[index], fit: BoxFit.cover),
          ),
        ),
      );
    }),
  );
}
}