import 'package:flutter/material.dart';
import 'package:bayt_alhikma_dashboard/utils/styles.dart';

import 'users/delete.dart';
import 'users/edit.dart';
import 'users/reports.dart';
class UserManagment extends StatefulWidget {
  const UserManagment({super.key});

  @override
  State<UserManagment> createState() => _UserManagmentState();
}

class _UserManagmentState extends State<UserManagment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.pageBackground,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryGold,
        title: const Text('User Management'),
      ),
      body: Container(
        child:ListView(
          children: [
            buttonCreation('Edit User', const editUser(), Icons.edit),
            SizedBox(height: 20),
            buttonCreation('Delete User', const deleteUser(), Icons.delete),
            SizedBox(height: 20),
            buttonCreation('Reports about User', const userReports(), Icons.report),
          ],
        )
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