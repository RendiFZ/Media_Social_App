import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rendi_art/pages/profil_page.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:rendi_art/ui/navbar_ui.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();

}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _bioController = TextEditingController();
  final picker = ImagePicker();
  File? _image;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var result = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        Directory.systemTemp.path + "/temp.jpg",
        quality: 88,
      );

      print(result?.lengthSync());

      setState(() {
        _image = result;
      });
    } else {
      print('No image selected.');
    }
  }

  Future uploadProfilePicture() async {
    if (_image == null) {
      return;
    }
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String filePath =
        'profils/Profils_$userId.png'; // Menambahkan 'profils/' ke awal jalur file
    await firebase_storage.FirebaseStorage.instance
        .ref(filePath)
        .putFile(_image!);
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(filePath)
        .getDownloadURL();

    await FirebaseFirestore.instance.collection('profils').doc(userId).update({
      'imageUrl': downloadURL,
      'userId': userId,
    });
  }

  Future updateProfile() async {
    try {
      await uploadProfilePicture();
      await updateBio();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Profil berhasil diperbarui'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MyNavBar()),
                  );
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Profil gagal diperbarui'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future updateBio() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('profils').doc(userId).update({
      'bio': _bioController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _image == null ? Text('No image selected.') : Image.file(_image!),
            ElevatedButton(
              onPressed: getImage,
              child: Text('Upload Profile Picture'),
            ),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
              ),
            ),
            ElevatedButton(
              onPressed: updateProfile,
              child: Text('Update Bio'),
            ),
          ],
        ),
      ),
    );
  }
}
