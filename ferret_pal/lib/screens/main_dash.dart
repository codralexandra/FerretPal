import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/profile_vm.dart';

import '../screens/session_screen.dart';

/// Main dashboard of the application
class Dashboard extends StatefulWidget{
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>{
  @override
  void initState(){
    super.initState();
    // Get the user information for data display
    _loadUserInfo();
  }

  // Asynchronously load the user information using the ProfileViewModel class
  Future<void> _loadUserInfo() async{
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen:false);
    await profileViewModel.getInfo();
  }

  @override
  Widget build(BuildContext context){
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    return Scaffold(
      // Custom Navbar Widget
      appBar: AppBar(
        title:
          Text(
            'Hello, ${profileViewModel.displayName}!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SessionScreen()),
          );
        },
        icon: Icon(Icons.access_time),
        label: Text('Start Session'),
      ),
      // Session widgets
    );
  }
}