import 'package:flutter/material.dart';
import 'book/add.dart';
import 'book/delete.dart';
import 'book/edit.dart';
import 'package:bayt_alhikma_dashboard/utils/styles.dart';

class BookManagment extends StatefulWidget {
  const BookManagment({super.key});

  @override
  State<BookManagment> createState() => _BookManagmentState();
}

class _BookManagmentState extends State<BookManagment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.pageBackground,
      appBar: AppBar(title: const Text('Book Management'),backgroundColor: AppStyles.lightBeige,),
      body: Container(
        child: ListView(
          children: [
            SizedBox(height: 20),
            buttonCreation('Add Book', const addBook(), Icons.add),
            SizedBox(height: 20),
            buttonCreation('Edit Book', const editBook(), Icons.edit),
            SizedBox(height: 20),
            buttonCreation('Delete Book', const deleteBook(), Icons.delete),
          ],
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
