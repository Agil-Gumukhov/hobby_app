import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profil extends StatefulWidget {
  final File? selectedImage;
  final String name;
  final String department;
  final String phone;
  final String email;

  const Profil({
    super.key,
    this.selectedImage,
    required this.name,
    required this.department,
    required this.phone,
    required this.email,
  });

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  File? selectedImage;
  String name = '';
  String department = '';
  String phone = '';
  String email = '';

  @override
  void initState() {
    super.initState();


    _loadProfileData();
  }

  /// SharedPreferences içindeki verileri yüklüyoruz
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    // Kaydettiğimiz key’lerle verileri çekiyoruz
    setState(() {
      name = prefs.getString('prof_name') ?? '';
      department = prefs.getString('prof_department') ?? '';
      phone = prefs.getString('prof_phone') ?? '';
      email = prefs.getString('prof_email') ?? '';

      final imagePath = prefs.getString('profile_image_path');
      if (imagePath != null && imagePath.isNotEmpty) {
        selectedImage = File(imagePath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            SizedBox(
              height: 100,
              width: 100,
              child: CircleAvatar(
                backgroundImage: selectedImage != null
                    ? FileImage(selectedImage!)
                    : null,
                child: selectedImage == null
                    ? const Icon(
                        Icons.person,
                        size: 50,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 40),
            ListTile(
              leading: const Icon(Icons.person_pin_rounded),
              title: const Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  name.isNotEmpty ? name : 'Henüz kaydedilmedi'),
            ),
            ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text(
                'Department',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(department.isNotEmpty
                  ? department
                  : 'Henüz kaydedilmedi'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text(
                'Phone no.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(phone.isNotEmpty
                  ? phone
                  : 'Henüz kaydedilmedi'),
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline_rounded),
              title: const Text(
                'E-Mail',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(email.isNotEmpty
                  ? email
                  : 'Henüz kaydedilmedi'),
            ),
          ],
        ),
      ),
    );
  }
}
