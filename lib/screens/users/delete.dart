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
  final _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  List<Map<String, dynamic>> listIssuedAccounts = [];
  List<Map<String, dynamic>> listUncompleteAccounts = [];
  @override
  void initState() {
    super.initState();
    getIssuedAccounts();
  }
  Future<void> getUncompleteAccounts() async {}
  Future<void> getIssuedAccounts() async {
    setState(() => isLoading = true);
    listIssuedAccounts = [];

    try {
      final querySnapshot = await _firestore.collection('profils').get();

      for (final doc in querySnapshot.docs) {
        int countDaysOfBan = 0;
        final banDaysMap = doc.data()['ban'];

        if (banDaysMap is Map) {
          for (final value in banDaysMap.values) {
            if (value is int) {
              countDaysOfBan += value;
            }
          }
        }

        if (countDaysOfBan >= 5) {
          listIssuedAccounts.add(doc.data());
        }
      }
    } catch (e) {
      debugPrint('Error fetching the accounts: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
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
                    '${listIssuedAccounts.length+listUncompleteAccounts.length}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text('Issued Accounts', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 20,),
            for(final account in listIssuedAccounts)
            accountsCard(account)
          ],
        ),
      ),
    );
  }

  Container accountsCard(Map<String, dynamic> accountProfile) {
    final username = accountProfile['username']?.toString() ?? '';
    final firstname = accountProfile['firstname']?.toString() ?? '';
    final lastname = accountProfile['lastname']?.toString() ?? '';
    final email = accountProfile['email']?.toString() ?? '';
    final avatar = accountProfile['avatar']?.toString() ?? '';
    final isMissingData = username.isEmpty || email.isEmpty || firstname.isEmpty || lastname.isEmpty || avatar.isEmpty;

    int numberOfBanDays() {
      int countDaysOfBan = 0;
      final banDaysMap = accountProfile['ban'];
      if (banDaysMap is Map) {
        for (final value in banDaysMap.values) {
          if (value is int) {
            countDaysOfBan += value;
          }
        }
      }
      return countDaysOfBan;
    }

    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: AppStyles.pageBackground,
        border: Border.all(color: AppStyles.primaryGold, width: 2.0),
      ),
      child: Row(
        children: [
          Badge(
            backgroundColor:isMissingData?Colors.amber:Colors.red,
            label: Row(
              children: [
                Icon(
                  isMissingData ? Icons.warning : Icons.error_outline,
                  color:Colors.white
                ),
                Text(isMissingData?'Uncompleted Account':'Issued Account',style: TextStyle(color: Colors.white),)
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.red,
              radius: 50,
              child: avatar.isNotEmpty
                  ? Image.asset('images/avatars/$avatar')
                  : Container(
                      color: Colors.red,
                      child: Text('Missing'),
                    ),
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('username: ${username.isNotEmpty ? username : 'missing'}'),
              Text('email: ${email.isNotEmpty ? email : 'missing'}'),
              Text('ban days: ${numberOfBanDays()}'),
            ],
          ),
        ],
      ),
    );
  }
}