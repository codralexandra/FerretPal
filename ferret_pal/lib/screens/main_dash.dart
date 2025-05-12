import 'package:ferret_pal/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/profile_vm.dart';

class Dashboard extends StatefulWidget{
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>{
  @override
  void initState(){
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async{
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen:false);
    await profileViewModel.getInfo();
  }

  @override
  Widget build(BuildContext context){
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    return Scaffold(
      appBar: CustomAppBar(title: 'Dashboard'),
    );
  }
}