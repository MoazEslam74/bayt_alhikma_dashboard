import 'package:bayt_alhikma_dashboard/model/book.dart';
import 'package:bayt_alhikma_dashboard/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class deleteBook extends StatefulWidget {
  const deleteBook({super.key});

  @override
  State<deleteBook> createState() => _deleteBookState();
}

class _deleteBookState extends State<deleteBook> {
  // تعريف متغير لتخزين جلب البيانات
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    // بدء عملية الجلب مرة واحدة عند تهيئة الواجهة
    _booksFuture = fetchBooks();
  }

  // نقل الدالة إلى داخل الـ State class لعدم تركها كـ Global Function
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
      throw e; // إرجاع الخطأ ليتم التقاطه في FutureBuilder
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
      // استخدام FutureBuilder للتعامل مع حالات الانتظار والبيانات والأخطاء
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          // حالة التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // حالة وجود خطأ
          else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading books: ${snapshot.error}'),
            );
          }
          // حالة عدم وجود بيانات
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books available.'));
          }

          // تم تحميل البيانات بنجاح
          final books = snapshot.data!;

          // استخدام ListView.builder أفضل من Column للقوائم القابلة للتمرير
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
              // إضافة معالجة الأخطاء للصور التالفة أو غير الموجودة
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                width: 100,
                height: 150,
                child: Icon(Icons.broken_image),
              ),
            ),
            // تغليف ListTile بـ Expanded لمنع أخطاء الـ Overflow داخل الـ Row
            Expanded(
              child: ListTile(
                title: Text(book.bookTitleEn),
                subtitle: Text(book.bookAuthorEn),
              ),
            ),
            InkWell(
              onTap: () {},
              child: IconButton(
                onPressed: () {},
                icon: Padding(
                  padding: EdgeInsetsGeometry.all(0.1),
                  child: Icon(Icons.delete_forever, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
