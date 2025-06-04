import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../view_models/profile_vm.dart';
import '../screens/main_dash.dart';

// Profile setup screen when first installing the application
class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  // Inputs
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  XFile? _profileImage;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  void _saveProfile() async {
    final String displayName = _displayNameController.text.trim();
    final String username = _usernameController.text.trim();

    if (username.isEmpty || displayName.isEmpty || _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a username, display name, and a profile picture.')),
      );
      return;
    }

    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    try {
      profileViewModel.setUsername(username);
      await profileViewModel.saveProfile(displayName, _profileImage!.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile setup complete!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) => Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        width: _currentPage == index ? 12 : 8,
        height: _currentPage == index ? 12 : 8,
        decoration: BoxDecoration(
          color: _currentPage == index ? Colors.lightGreen : Colors.grey,
          shape: BoxShape.circle,
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildSlide(
                  title: "Welcome to PosturePal",
                  content: "Improve your posture using our Pomodoro-style tracker.",
                ),
                _buildSlide(
                  title: "Stay Consistent",
                  content: "Track your focus and posture with real-time feedback.",
                ),
                _buildSetupSlide()
              ],
            ),
          ),
          _buildDotIndicator(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSlide({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text(content, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSetupSlide() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Start your journey today!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Set up your profile below',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
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
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
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
                      child: Text('Finish Setup'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
