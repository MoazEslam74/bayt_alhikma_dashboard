import 'package:bayt_alhikma_dashboard/model/book.dart';
import 'package:bayt_alhikma_dashboard/utils/styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class deleteBook extends StatefulWidget {
  const deleteBook({super.key});

  @override
  State<deleteBook> createState() => _deleteBookState();
}

class _deleteBookState extends State<deleteBook> {
  
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();

    _booksFuture = fetchBooks();
  }

  Future<void> deleteBook(Book deletedBook) async {
    if (Firebase.apps.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Firebase is not initialized. Configure Firebase first.',
          ),
        ),
      );
      return;
    }
    try {
      final query = await FirebaseFirestore.instance
          .collection('books')
          .where('ID', isEqualTo: deletedBook.bookId)
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _booksFuture = fetchBooks();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book deleted successfully')),
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to delete book: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete book: $e')));
    }
  }

  
  Future<List<Book>> fetchBooks() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('books')
          .get();

      return querySnapshot.docs.map((doc) {
        return Book(
          bookId: doc['ID'],
          bookTitleEn: doc['nameEN'],
          bookTitleAr: doc['nameAR'],
          bookAuthorEn: doc['authorEN'],
          bookAuthorAr: doc['authorAR'],
          bookDescriptionEn: doc['descriptionEN'],
          bookDescriptionAr: doc['descriptionAR'],
          bookCategory: doc['category'],
          bookImageUrl: doc['image'] ?? "Null",
          bookAudioUrl: doc['audio'] ?? "Null",
          bookPdfUrl: doc['pdf'] ?? "Null",
          bookPrice: doc['price'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching books: $e');
      throw e; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.pageBackground,
      appBar: AppBar(
        title: const Text('Delete Book'),
        backgroundColor: AppStyles.lightBeige,
      ),
      
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          // Loading state 
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Error state
          else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading books: ${snapshot.error}'),
            );
          }
          // No data state
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books available.'));
          }

          
          final books = snapshot.data!;

          
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              return buildBookItem(books[index]);
            },
          );
        },
      ),
    );
  }

  Widget buildBookItem(Book book) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.network(
              book.bookImageUrl,
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              // Error in the image 
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                width: 100,
                height: 150,
                child: Icon(Icons.broken_image),
              ),
            ),
            
            Expanded(
              child: ListTile(
                title: Text(book.bookTitleEn),
                subtitle: Text(book.bookAuthorEn),
              ),
            ),
            IconButton(
              onPressed: () {
                
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return warnningMessage(context,book); 
                  },
                );
              },
              icon: const Padding(
                padding: EdgeInsets.all(0.1),
                child: Icon(Icons.delete_forever, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Dialog warnningMessage(BuildContext context, Book deletedBook) {
    return Dialog(
      backgroundColor: Colors.transparent, 
      child: Container(
        padding: const EdgeInsets.all(
          20.0,
        ), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, 
          children: [
            const Text(
              'Are you sure you want to delete this book?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), 
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    deleteBook(deletedBook);
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Yes',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
