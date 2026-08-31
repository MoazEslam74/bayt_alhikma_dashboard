import 'package:bayt_alhikma_dashboard/model/avatars.dart';
import 'package:bayt_alhikma_dashboard/model/report.dart';
import 'package:bayt_alhikma_dashboard/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bayt_alhikma_dashboard/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class userReports extends StatefulWidget {
  const userReports({super.key});

  @override
  State<userReports> createState() => _userReportsState();
}

class _userReportsState extends State<userReports> {
  final _firestore = FirebaseFirestore.instance;
  final avatars_list = Avatars().getAvatars();
  List<User> reportedUsers = [];
  List<Map<String, dynamic>> Reports = [];
  bool isLoading = false;

  Future<List<QuerySnapshot<Map<String, dynamic>>>> getUserProfile(
    String defendant,
    String reporter,
  ) async {
    try {
      final defendantSnapshot = await _firestore
          .collection('profils')
          .where('username', isEqualTo: defendant)
          .get();

      final reporterSnapshot = await _firestore
          .collection('profils')
          .where('username', isEqualTo: reporter)
          .get();

      return [reporterSnapshot, defendantSnapshot];
    } catch (e) {
      debugPrint('Error fetching Users: $e');
      return [];
    }
  }

  Future<void> getReports() async {
    setState(() => isLoading = true);
    try {
      final querySnapshot = await _firestore.collection('reports').get();
      final List<Map<String, dynamic>> fs_reports = [];
      for (var doc in querySnapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        fs_reports.add(data);
      }
      setState(() {
        Reports = fs_reports;
      });
    } catch (e) {
      // handle error or log
      debugPrint('Error fetching reports: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getReports();
  }

  Future<void> applyBan(String username, int banDays) async {
    try {
      final querySnapshot = await _firestore
          .collection('profils')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No profile found for username: $username');
        return;
      }

      final profileDoc = querySnapshot.docs.first;
      final currentData = profileDoc.data();
      final currentBan = Map<String, dynamic>.from(currentData['ban'] ?? {});
      final banKey = 'banDays_${Timestamp.now().toDate()}';

      currentBan[banKey] = banDays;

      await profileDoc.reference.update({'ban': currentBan});
    } catch (e) {
      debugPrint('Error applying the ban: $e');
    }
  }

  Future<bool> checkDefendantState(String defendant) async {
    try {
      final querySnapshot = await _firestore
          .collection('profils')
          .where('username', isEqualTo: defendant)
          .get();
      int countDaysOfBan = 0;
      for (final doc in querySnapshot.docs) {
        final banDaysMap = doc.data()['ban'];
        if (banDaysMap is Map) {
          for (final key in banDaysMap.keys) {
            final value = banDaysMap[key];
            countDaysOfBan += value as int;
            if ( countDaysOfBan >= 5) {
              return true;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking defendant state: $e');
    }
    return false;
  }

  Future<void> deleteUser(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('profils')
          .where('username', isEqualTo: username)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error in deleting the user account: $e');
    }
  }

  Future<void> deleteReport(int reportID, bool forRejection) async {
    try {
      final querySnapshot = await _firestore
          .collection('reports')
          .where('ID', isEqualTo: reportID)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      await getReports();
    } catch (e) {
      debugPrint('Error in deleting the report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
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
                    '${Reports.length}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text('Report', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            for (final report in Reports)
              FutureBuilder<List<QuerySnapshot<Map<String, dynamic>>>>(
                future: getUserProfile(
                  report['defendant'] as String,
                  report['reporter'] as String,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return SizedBox();
                  }

                  final profiles = snapshot.data!;
                  return _reportedUser(
                    report['ID'] as int,
                    report['defendant'] as String,
                    profiles[0],
                    profiles[1],
                    report['reporter'] as String,
                    report['reason'] as String,
                    report['timestamp'] as Timestamp,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Container _reportedUser(
    int reportID,
    String defendant,
    QuerySnapshot<Map<String, dynamic>> profile_rep,
    QuerySnapshot<Map<String, dynamic>> profile_def,
    String reporter,
    String reason,
    Timestamp timestamp,
  ) {
    final dateTime = timestamp.toDate().toLocal();
    final formattedTimestamp =
        '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
    late TextEditingController numberOfBanDays;
    numberOfBanDays = TextEditingController();
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: AppStyles.pageBackground,
        border: Border.all(color: AppStyles.primaryGold, width: 2.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Badge(
            backgroundColor: Colors.blue,
            label: Text('Reporter', style: TextStyle(fontSize: 18)),
            offset: Offset(-70, 105),
            child: Column(
              children: [
                Text(
                  reporter,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                CircleAvatar(
                  radius: 45,
                  child: Image.asset(
                    'images/avatars/${profile_rep.docs.first.data()['avatar']}',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(AppStyles.lightBeige),
                  foregroundColor: WidgetStatePropertyAll(Colors.red),
                ),
                onPressed: () {
                  showDialog(
                    fullscreenDialog: false,
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
              SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(AppStyles.lightBeige),
                  foregroundColor: WidgetStatePropertyAll(
                    AppStyles.primaryGold,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    fullscreenDialog: false,
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: Text('Actions'),
                        content: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      content: Text(
                                        'Are you sure you want to delete this account?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {},
                                          child: Text('Yes'),
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          child: Text('No'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text('Delete this user'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  fullscreenDialog: false,
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      content: Column(
                                        children: [
                                          Text(
                                            'How many days of ban you will give to the user?',
                                          ),

                                          TextField(
                                            controller: numberOfBanDays,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            applyBan(
                                              defendant,
                                              int.parse(numberOfBanDays.text),
                                            );
                                            deleteReport(reportID, false);
                                            Navigator.of(ctx).pop();
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Text('Apply'),
                                        ),
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
                              child: Text('Ban the user'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      content: Text(
                                        'Are you sure you want to reject this report?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            deleteReport(reportID, true);
                                            Navigator.of(ctx).pop();
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Text('Yes'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: Text('No'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text('Reject the report'),
                            ),
                          ],
                        ),
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
                child: Row(
                  children: [
                    Icon(Icons.settings_applications),
                    Text('Actions'),
                  ],
                ),
              ),

              SizedBox(height: 10),
              Text(formattedTimestamp),
            ],
          ),
          SizedBox(width: 15),
          Badge(
            label: Text('Defendant', style: TextStyle(fontSize: 18)),
            offset: Offset(-75, 105),
            child: Column(
              children: [
                Text(
                  defendant,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                CircleAvatar(
                  radius: 45,
                  child: Image.asset(
                    'images/avatars/${profile_def.docs.first.data()['avatar']}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
