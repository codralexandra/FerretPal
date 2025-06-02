import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget{
  final String title;
  final String value;
  final IconData icon;

  const BadgeWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context){
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Colors.green[700],
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
      backgroundColor: Colors.lightGreen,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}