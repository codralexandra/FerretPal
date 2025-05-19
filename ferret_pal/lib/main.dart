import 'package:ferret_pal/screens/main_dash.dart';
import 'package:ferret_pal/screens/profile_setup.dart';
import 'package:ferret_pal/services/profile_service.dart';
import 'package:ferret_pal/view_models/profile_vm.dart';
import 'package:ferret_pal/view_models/session_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  print("Flutter app starting!");
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProfileViewModel()),
          ChangeNotifierProvider(create: (_) => SessionViewModel()),
        ],
        child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkProfileExists() async {
    final profileViewModel = ProfileViewModel();
    return await profileViewModel.profileExists();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FerretPal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder<bool>(
        future: _checkProfileExists(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError){
            return const Scaffold(
              body: Center(child: Text('Error loading profile status')),
            );
          } else{
            final exists = snapshot.data ?? false;
            return exists ? const Dashboard(): const ProfileSetup();
          }
        }
      )
    );
  }
}