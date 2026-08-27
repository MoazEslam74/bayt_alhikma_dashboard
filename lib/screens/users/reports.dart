import 'package:flutter/material.dart';
import 'package:bayt_alhikma_dashboard/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class userReports extends StatefulWidget {
  const userReports({super.key});

  @override
  State<userReports> createState() => _userReportsState();
}

class _userReportsState extends State<userReports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.pageBackground,
      appBar: AppBar(
        title: Text('Reports'),
        backgroundColor: AppStyles.primaryGold,
      ),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                Text('####',style: TextStyle(fontSize: 22),),
                Text('reorts',style: TextStyle(fontSize: 16),)
              ],
            ),
          )
        ],
      ),
    );
  }
}