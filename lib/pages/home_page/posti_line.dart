import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'komentar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PostCard extends StatefulWidget {
  final DocumentSnapshot document;
  final String currentUserId;

  PostCard({required this.document, required this.currentUserId});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLoved = false;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;
    DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(timestamp);

    List<String> imageUrls = List<String>.from(data['imageUrls'] ?? []);
    int loveCount = data['loveCount'] ?? 0;
    String userId = data['userId'];

    return Card(
      margin: const EdgeInsets.all(8.0), // Ini adalah margin untuk kartu
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0), // Ini adalah padding untuk teks
            child: FutureBuilder<String>(
              future: firebase_storage.FirebaseStorage.instance
                  .ref('profils/Profils_${data['userId']}.png')
                  .getDownloadURL(), // Mengambil URL download untuk foto profil
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Menampilkan indikator loading selama data sedang dimuat
                } else {
                  if (snapshot.hasError) {
                    return const Icon(Icons.account_circle,
                        size:
                            80.0); // Jika terjadi kesalahan saat mengambil foto profil dari Firebase, gunakan ikon profil default dari Flutter
                  } else {
                    return Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: Image.network(snapshot.data!)
                              .image, // Jika berhasil mengambil foto profil dari Firebase, gunakan foto profil tersebut
                          radius:
                              20.0, // Anda bisa mengubah radius sesuai kebutuhan
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Posted by ${data['username']} on $formattedDate', // Ini adalah teks yang menampilkan pengguna dan tanggal
                          style: const TextStyle(
                              fontSize: 12.0), // Ini adalah gaya untuk teks
                        ),
                      ],
                    );
                  }
                }
              },
            ),
          ),
          ListTile(
            title: Text(data['caption']), // Ini adalah judul untuk ListTile
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.comment), // Ini adalah ikon untuk komentar
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KomentarPage(
                            document: widget
                                .document), // Ini adalah fungsi yang dipanggil saat tombol komentar ditekan
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    isLoved
                        ? Icons.favorite
                        : Icons
                            .favorite_border, // Ini adalah ikon untuk favorit
                    color: isLoved
                        ? Colors.red
                        : null, // Ini adalah warna untuk ikon favorit
                  ),
                  onPressed: () {
                    setState(() {
                      isLoved =
                          !isLoved; // Ini adalah fungsi yang dipanggil saat tombol favorit ditekan
                      loveCount = isLoved
                          ? loveCount + 1
                          : loveCount -
                              1; // Ini adalah penghitungan jumlah favorit
                    });
                    widget.document.reference.update({
                      'loveCount': loveCount
                    }); // Ini adalah pembaruan jumlah favorit
                  },
                ),
                Text(
                    '$loveCount'), // Ini adalah teks yang menampilkan jumlah favorit
                if (userId == widget.currentUserId)
                  IconButton(
                    icon: const Icon(Icons.delete), // Ini adalah ikon untuk menghapus
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title:
                                const Text('Delete Post'), // Ini adalah judul dialog
                            content: const Text(
                                'Are you sure you want to delete this post?'), // Ini adalah konten dialog
                            actions: <Widget>[
                              TextButton(
                                child:
                                    const Text('Cancel'), // Ini adalah tombol batal
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Ini adalah fungsi yang dipanggil saat tombol batal ditekan
                                },
                              ),
                              TextButton(
                                child:
                                    const Text('Delete'), // Ini adalah tombol hapus
                                onPressed: () {
                                  widget.document.reference
                                      .delete(); // Ini adalah fungsi yang dipanggil saat tombol hapus ditekan
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                      child: AspectRatio(
                    aspectRatio: 1,
                    child: ListView.builder(
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              Navigator.pop(
                                  context); // Ini adalah fungsi yang dipanggil saat gambar ditekan
                            },
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(imageUrls[index],
                                  fit: BoxFit
                                      .cover), // Ini adalah gambar yang ditampilkan
                            ));
                      },
                    ),
                  ));
                },
              );
            }, // Ini adalah fungsi yang dipanggil saat gambar ditekan
            child: GridView.count(
              shrinkWrap:
                  true, // Ini adalah properti yang mengatur apakah GridView harus berukuran sesuai dengan kontennya
              physics:
                  const NeverScrollableScrollPhysics(), // Ini adalah properti yang mengatur perilaku scroll dari GridView
              crossAxisCount: 2, // Ini adalah jumlah kolom dalam GridView
              childAspectRatio:
                  1.0, // Ini adalah rasio antara lebar dan tinggi setiap anak dalam GridView
              mainAxisSpacing:
                  4.0, // Ini adalah jarak antara setiap anak di sumbu utama
              crossAxisSpacing:
                  4.0, // Ini adalah jarak antara setiap anak di sumbu silang
              children: imageUrls
                  .map((imageUrl) => Padding(
                        padding: const EdgeInsets.all(
                            4.0), // Ini adalah padding untuk setiap gambar
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10.0), // Ini adalah radius sudut untuk setiap gambar
                          child: Image.network(imageUrl,
                              fit: BoxFit
                                  .cover), // Ini adalah gambar yang ditampilkan
                        ),
                      ))
                  .toList(), // Ini adalah daftar gambar yang ditampilkan dalam GridView
            ),
          ),
        ],
      ),
    );
  }
}
