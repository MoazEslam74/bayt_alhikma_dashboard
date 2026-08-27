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
                  '####',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text('Report', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _reportedUser(
    String defendant,
    String imgURL,
    String reporter,
    String reason,
    Timestamp timestamp,
  ) {
    return Container(
      child: Row(
        children: [
          ///Img
          Column(
            children: [
              Text(defendant),
              Text(reporter),
              Text('$timestamp'),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: Text('Reason of the report'),
                        content: Text(reason),
                        actions: [
                          TextButton(
                          onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: Text('Cancel'),
                          ),            
                        ],
                      );
                    },
                  );
                },
                child: Row(children: [Icon(Icons.report), Text('Reason')]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
