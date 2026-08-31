import 'package:bayt_alhikma_dashboard/utils/styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class deleteUser extends StatefulWidget {
  const deleteUser({super.key});

  @override
  State<deleteUser> createState() => _deleteUserState();
}

class _deleteUserState extends State<deleteUser> {
  final bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(inAsyncCall: isloading,child: Scaffold(
      backgroundColor: AppStyles.pageBackground,
        appBar: AppBar(
          title: Text('Delete issued accounts'),
          backgroundColor: AppStyles.primaryGold,
        ),
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: AppStyles.lightBeige,
                border: Border.all(color: AppStyles.primaryGold),
              ),
              child: Column(
                children: [
                  Text(
                    '###',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text('Issued Accounts', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
    ),);
  }
}
