import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profilduzenle extends StatefulWidget {
  final File? selectedImage;
  final String name;
  final String department;
  final String phone;
  final String email;

  const Profilduzenle({
    super.key,
    this.selectedImage,
    required this.name,
    required this.department,
    required this.phone,
    required this.email,
  });

  @override
  State<Profilduzenle> createState() => _ProfilduzenleState();
}

class _ProfilduzenleState extends State<Profilduzenle> {
  File? selectedImage;

  late TextEditingController nameController;
  late TextEditingController departmentController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    selectedImage = widget.selectedImage;
    nameController = TextEditingController(text: widget.name);
    departmentController = TextEditingController(text: widget.department);
    phoneController = TextEditingController(text: widget.phone);
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    departmentController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an option'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take a photo'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_album),
                  title: Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    pickImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Bu fonksiyon SharedPreferences üzerinden profil verilerini kaydediyor
  Future<void> saveProfileData({
    required String name,
    required String department,
    required String phone,
    required String email,
    required File? selectedImageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('prof_name', name);
    await prefs.setString('prof_department', department);
    await prefs.setString('prof_phone', phone);
    await prefs.setString('prof_email', email);

    if (selectedImageFile != null) {
      await prefs.setString('profile_image_path', selectedImageFile.path);
    } else {
      await prefs.remove('profile_image_path');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : null,
                  radius: 50,
                  child: selectedImage == null
                      ? const Text(
                          'Select an image',
                          textAlign: TextAlign.center,
                        )
                      : null,
                ),
                Positioned(
                  bottom: -10,
                  right: -25,
                  
                  child: RawMaterialButton(
                    onPressed: _showImageSourceDialog,
                    elevation: 2.0,
                    fillColor: const Color(0xFFF5F6F9),
                    padding: const EdgeInsets.all(5.0),
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            ListTile(
              leading: Icon(Icons.person_pin_rounded),
              title: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: TextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.business_outlined),
              title: Text(
                'Department',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: TextField(
                controller: departmentController,
                decoration: InputDecoration(
                  hintText: 'Enter your department',
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(
                'Phone no.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.mail_outline_rounded),
              title: Text(
                'E-Mail',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                ),
              ),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isEmpty ||
                    phoneController.text.isEmpty ||
                    nameController.text.isEmpty ||
                    departmentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  await saveProfileData(
                    name: nameController.text,
                    department: departmentController.text,
                    phone: phoneController.text,
                    email: emailController.text,
                    selectedImageFile: selectedImage,
                  );

                  // Kaydetme işlemi bitince Profili gösteren sayfaya geri dönebilir veya
                  // bir önceki sayfaya dönüldüğünde veriler güncellenecektir.
                  // Örnek: Navigator.pop(context); diyebilirsiniz.
                  Navigator.pop(context, {
                    'selectedImage': selectedImage,
                    'name': nameController.text,
                    'department': departmentController.text,
                    'phone': phoneController.text,
                    'email': emailController.text,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(200, 50),
              ),
              child: Text(
                'Save',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
