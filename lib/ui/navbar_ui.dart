import 'package:flutter/material.dart';
import 'package:rendi_art/akun_page/login.dart';
import 'package:rendi_art/pages/home_page/home_page.dart';
import 'package:rendi_art/pages/posting_page.dart';
import 'package:rendi_art/pages/profil_page.dart';
import 'package:rendi_art/pages/search_page.dart';
// ignore: unused_import
import 'package:rendi_art/ui/navbar_ui.dart';
import 'package:rendi_art/auth.dart'; // Ganti dengan path AuthService Anda

class MyNavBar extends StatefulWidget {
  @override
  _MyNavBarState createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SearchPage(),
    PostingPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        hintColor: Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Drei Art Thread'),
          centerTitle: true, // This centers the title
          actions: _selectedIndex == 3
              ? <Widget>[
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () async {
                      // Implement your logout logic here
                      await AuthService.logOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ]
              : null,
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box), // Ganti ikon ini
              label: 'Post', // Ganti label ini
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          unselectedItemColor:
              Colors.white, // Mengubah warna ikon menjadi putih
          selectedItemColor: Colors
              .orange, // Mengubah warna ikon yang sedang dipilih menjadi oranye
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
