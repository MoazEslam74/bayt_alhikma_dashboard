import 'package:flutter/material.dart';
import '../utils/styles.dart';
import 'book_managment.dart';
import 'user_managment.dart';
import 'analytics_screen.dart';
import'chat_managment.dart';
import'../utils/styles.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.pageBackground,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryGold,
        title: const Text('Bayt AlHikma Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              children: [
                buildGridItem('Users', Icons.person, const UserManagment()),
                buildGridItem('Books', Icons.book, const BookManagment()),
                buildGridItem('Chats', Icons.chat, const ChatManagment()),
                buildGridItem('Analytics', Icons.analytics, const AnalyticsScreen()),
              ],
            ),
            const SizedBox(height: 16),
            Image.asset('images/logo_placeholder.png', width: 150),
            SizedBox(height:20),
            const Text(
              'The system dashboard is designed to provide a comprehensive overview of the application\'s performance and user engagement',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    
  }

  InkWell buildGridItem(String title, IconData icon,Widget? destinationScreen) {
    return InkWell(
      onTap: () {
        if (destinationScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationScreen!),
          );
        }
      },
      child: Container(
        
        
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: AppStyles.primaryGold),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}