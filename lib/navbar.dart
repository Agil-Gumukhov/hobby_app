// lib/navbar.dart
import 'dart:io';
import 'package:firstapp/Dilde%C4%9Fi%C5%9Ftirme.dart';
import 'package:firstapp/pages/%C4%B0zlenecekler.dart';
import 'package:firstapp/pages/RestaurantSayfa.dart';
import 'package:firstapp/pages/Sport_sayfas%C4%B1.dart';
import 'package:firstapp/pages/Haberler.dart';
import 'package:firstapp/pages/ProfilDuzenle.dart';
import 'package:firstapp/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:firstapp/generated/l10n.dart';
import 'package:provider/provider.dart';

// Import the pages
import 'package:firstapp/pages/anasayfa.dart';
import 'package:firstapp/pages/profil.dart';

class Navbar extends StatefulWidget {
  final Future<Haberler> haberler;
  final File? selectedImage;
  final String name;
  final String department;
  final String phone;
  final String email;

  const Navbar({
    super.key,
    required this.haberler,
    required this.selectedImage,
    required this.name,
    required this.department,
    required this.phone,
    required this.email,
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  // We store the profile data here
  File? selectedImage;
  String name = '';
  String department = '';
  String phone = '';
  String email = '';

  // The current tab index
  int selectIndex = 2;

  // This integer will increment each time we edit the profile
  // which changes the `ValueKey`, forcing Profil to rebuild
  int profileVersion = 0;

  @override
  void initState() {
    super.initState();
    // Initialize local variables from constructor
    selectedImage = widget.selectedImage;
    name = widget.name;
    department = widget.department;
    phone = widget.phone;
    email = widget.email;
  }

  void pageChange(int index) {
    setState(() {
      selectIndex = index;
    });
  }

  @override
  void didUpdateWidget(Navbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.haberler != widget.haberler && selectIndex == 2) {
      setState(() {
        // If needed, do something when "haberler" changes
      });
    }
  }

  String getTitle(int index) {
    switch (index) {
      case 0:
        return S.of(context).restaurant;
      case 1:
        return S.of(context).movies;
      case 2:
        return S.of(context).homepage;
      case 3:
        return S.of(context).sportleague;
      case 4:
        return S.of(context).profil;
      default:
        return "App";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the list of pages
    final List<Widget> pages = [
      Restaurantsayfa(),
      Izlenecekler(),
      Anasayfa(haberler: widget.haberler),
      SportSayfa(),
      Profil(
        key: ValueKey(profileVersion), // <--- This is critical
        selectedImage: selectedImage,
        name: name,
        department: department,
        phone: phone,
        email: email,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTitle(selectIndex),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Show edit button only on Profil tab
          if (selectIndex == 4)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                // Navigate to Profilduzenle
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profilduzenle(
                      selectedImage: selectedImage,
                      name: name,
                      department: department,
                      phone: phone,
                      email: email,
                    ),
                  ),
                );

                // If we got a result, update local state
                if (result != null) {
                  setState(() {
                    selectedImage = result['selectedImage'];
                    name = result['name'];
                    department = result['department'];
                    phone = result['phone'];
                    email = result['email'];

                    // Increment profileVersion so we get a new Key
                    // -> forcing Profil to rebuild
                    profileVersion++;
                  });
                }
              },
            )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Image.asset('assets/images/haber.png')),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    onTap: () {},
                    leading: const Icon(Icons.person),
                    title: Text(S.of(context).profil),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SportSayfa(),
                        ),
                      );
                    },
                    leading: const Icon(Icons.sports_soccer),
                    title: Text(S.of(context).sportleague),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: const Icon(Icons.movie_creation_outlined),
                    title: Text(S.of(context).movies),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Dildegistirme(
                            haberler: widget.haberler,
                          ),
                        ),
                      );
                    },
                    leading: const Icon(Icons.settings),
                    title: Text(S.of(context).settings),
                  ),
                  SwitchListTile(
                    title: Row(
                      children: [
                        Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.nightlight_round
                              : Icons.wb_sunny,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          Theme.of(context).brightness == Brightness.dark
                              ? S.of(context).darkmode
                              : S.of(context).lightmode,
                        ),
                      ],
                    ),
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (bool value) {
                      // Toggle theme
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey
            : Colors.black54,
        currentIndex: selectIndex,
        onTap: pageChange,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_sharp),
            label: S.of(context).restaurant,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.movie_outlined),
            label: S.of(context).movies,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: S.of(context).homepage,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.sports_soccer),
            label: S.of(context).sportleague,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: S.of(context).profil,
          ),
        ],
      ),
      body: pages[selectIndex],
    );
  }
}
