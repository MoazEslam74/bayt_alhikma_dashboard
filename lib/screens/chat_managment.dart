import 'package:bayt_alhikma_dashboard/screens/chats/control.dart';
import 'package:bayt_alhikma_dashboard/screens/chats/delete.dart';
import 'package:flutter/material.dart';
import '../utils/styles.dart';
class ChatManagment extends StatefulWidget {
  const ChatManagment({super.key});

  @override
  State<ChatManagment> createState() => _ChatManagmentState();
}

class _ChatManagmentState extends State<ChatManagment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Management'),
      ),
      body: Container(
        child: Container(
        child: ListView(
          children: [
            SizedBox(height: 20),
            buttonCreation('Control Chats', const controlChats(), Icons.settings),
            SizedBox(height: 20),
            buttonCreation('Delete Chats', const deleteChats(), Icons.delete),
            
          ],
        ),
      ),
      ),
      );
    
  }

  InkWell buttonCreation(String name, Widget destination, IconData icon) {
    return InkWell(
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination!),
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.15,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: AppStyles.primaryGold),
            SizedBox(width: 16),
            Text(name, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}