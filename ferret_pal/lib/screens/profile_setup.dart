import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../view_models/profile_vm.dart';
import '../screens/main_dash.dart';

// Profile setup screen when first installing the application
class ProfileSetup extends StatefulWidget{

  const ProfileSetup({super.key});

  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  // Display name input
  final TextEditingController _displayNameController = TextEditingController();
  // Profile picture input
  XFile? _profileImage;

  // Asynchronously pick an image from the device using the ImagePicker package
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  // Asynchronously save the user information using the ProfileViewModel class
  void _saveProfile() async {
    final String displayName = _displayNameController.text.trim();
    if (displayName.isEmpty || _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a display name and a profile picture.')),
      );
      return;
    }

    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    // Try saving the information, and throw a message if an error occurs
    try {
      await profileViewModel.saveProfile(displayName, _profileImage!.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile setup complete!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context)=>Dashboard()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(File(_profileImage!.path))
                    : null,
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}