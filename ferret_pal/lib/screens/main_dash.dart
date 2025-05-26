import 'package:ferret_pal/widgets/last_session_overview.dart';
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
  final GlobalKey<LastSessionOverviewState> _lastSessionKey = GlobalKey();

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

  void _refreshWidgets() {
    _lastSessionKey.currentState?.refreshData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello, ${profileViewModel.displayName}!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Reload user info or anything else
          await _loadUserInfo();
          // Refresh the last session widget
          _refreshWidgets();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(), // needed for RefreshIndicator to work when list is short
          children: [
            LastSessionOverview(key: _lastSessionKey),
            // more widgets here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SessionScreen()),
          );
        },
        icon: const Icon(Icons.access_time),
        label: const Text('Start Session'),
      ),
    );
  }
}