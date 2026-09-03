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
    getUncompleteAccounts();
  }
  Future<void> deleteIssuedAccount(String username,bool isIssuedAccount,bool isMissingData)async{
    setState(() => isLoading = true);
              try {
                final querySnapshot = await _firestore
                    .collection('profils')
                    .where('username', isEqualTo: username)
                    .get();

                for (final doc in querySnapshot.docs) {
                  await doc.reference.delete();
                }

                if (isIssuedAccount) {
                  listIssuedAccounts.removeWhere((account) => account['username'] == username);
                } else if (isMissingData) {
                  listUncompleteAccounts.removeWhere((account) => account['username'] == username);
                }
              } catch (e) {
                debugPrint('Error deleting the account: $e');
              } finally {
                setState(() => isLoading = false);
              }
  }
  Future<void> getUncompleteAccounts() async {
    setState(() => isLoading = true);
    try {
      final querySnapshot = await _firestore.collection('profils').get();
      for (final doc in querySnapshot.docs) {
        final data = doc.data();

        final username = data['username']?.toString().trim() ?? '';
        final firstname = data['firstname']?.toString().trim() ?? '';
        final lastname = data['lastname']?.toString().trim() ?? '';
        final email = data['email']?.toString().trim() ?? '';
        final avatar = data['avatar']?.toString().trim() ?? '';

        final isMissingData = username.isEmpty ||
            firstname.isEmpty ||
            lastname.isEmpty ||
            email.isEmpty ||
            avatar.isEmpty;

        if (isMissingData) {
          listUncompleteAccounts.add(data);
        }
        print('${listUncompleteAccounts.length} Uncomplete Accounts');
      }
    } catch (e) {
      debugPrint('Error fetching the accounts: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

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
          title: Text('Manage issued accounts'),
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
                    '${listIssuedAccounts.length + listUncompleteAccounts.length}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text('Issued Accounts', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 20),
            for (final account in listIssuedAccounts) accountsCard(account, true, false),
            for (final account in listUncompleteAccounts) accountsCard(account, false, true),
          ],
        ),
      ),
    );
  }

  Container accountsCard(Map<String, dynamic> accountProfile,bool isIssuedAccount,bool isMissingData) {
    final username = accountProfile['username']?.toString().trim() ?? '';
    final firstname = accountProfile['firstname']?.toString().trim() ?? '';
    final lastname = accountProfile['lastname']?.toString().trim() ?? '';
    final email = accountProfile['email']?.toString().trim() ?? '';
    final avatar = accountProfile['avatar']?.toString().trim() ?? '';

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
            backgroundColor: isMissingData ? Colors.amber : Colors.red,
            label: Row(
              children: [
                Icon(
                  isMissingData ? Icons.warning : Icons.error_outline,
                  color: Colors.white,
                ),
                Text(
                  isMissingData ? 'Uncompleted Account' : 'Issued Account',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.red,
              radius: 50,
              child: avatar.isNotEmpty
                  ? Image.asset('images/avatars/$avatar')
                  : Container(color: Colors.red, child: Text('Missing')),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('username: ${username.isNotEmpty ? username : 'missing'}'),
                Text(
                  'email: ${email.isNotEmpty ? email : 'missing'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('ban days: ${numberOfBanDays()}'),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: (){
                  deleteIssuedAccount(username,isIssuedAccount,isMissingData);
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(80, 40),
                  padding:EdgeInsets.symmetric(horizontal: 15, vertical: 1),
                  backgroundColor: AppStyles.primaryGold,
                ),
                child: Column(
                  children: [
                    Icon(Icons.delete,color:Colors.white),
                    Text('Delete',style:TextStyle(color:Colors.white)),
                  ],
                ),
              ),
              isMissingData?
              ElevatedButton(
                onPressed: (){
                  
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(80, 40),
                  padding:EdgeInsets.symmetric(horizontal: 15, vertical: 1),
                  backgroundColor: AppStyles.primaryGold,
                ),
                child: Column(
                  children: [
                    Icon(Icons.edit,color:Colors.white),
                    Text('Edit ',style:TextStyle(color:Colors.white)),
                  ],
                ),
              ):SizedBox(height: 0,),
            ],
          )
        ],
      ),
    );
  }
}
