import 'package:bayt_alhikma_dashboard/model/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../utils/styles.dart';

class EditBookScreen extends StatefulWidget {
  final Book directBook;
  const EditBookScreen({super.key, required this.directBook});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  late TextEditingController bookIdController;
  late TextEditingController bookTitleEnController;
  late TextEditingController bookTitleArController;
  late TextEditingController authorEnController;
  late TextEditingController authorArController;
  late TextEditingController descriptionEnController;
  late TextEditingController descriptionArController;
  late TextEditingController categoryController;
  late TextEditingController imageUrlController;
  late TextEditingController audioUrlController;
  late TextEditingController pdfUrlController;
  late TextEditingController priceController;
  late Book directBook = widget.directBook;
  @override
  void initState() {
    super.initState();
    bookIdController = TextEditingController(text: directBook.bookId);
    bookTitleEnController = TextEditingController(text: directBook.bookTitleEn);
    bookTitleArController = TextEditingController(text: directBook.bookTitleAr);
    authorEnController = TextEditingController(text: directBook.bookAuthorEn);
    authorArController = TextEditingController(text: directBook.bookAuthorAr);
    descriptionEnController = TextEditingController(text: directBook.bookDescriptionEn);
    descriptionArController = TextEditingController(text: directBook.bookDescriptionAr);
    categoryController = TextEditingController(text: directBook.bookCategory);
    imageUrlController = TextEditingController(text: directBook.bookImageUrl);
    audioUrlController = TextEditingController(text: directBook.bookAudioUrl);
    pdfUrlController = TextEditingController(text: directBook.bookPdfUrl);
    priceController = TextEditingController(text: "${directBook.bookPrice}");
  }

  @override
  void dispose() {
    bookIdController.dispose();
    bookTitleEnController.dispose();
    bookTitleArController.dispose();
    authorEnController.dispose();
    authorArController.dispose();
    descriptionEnController.dispose();
    descriptionArController.dispose();
    categoryController.dispose();
    imageUrlController.dispose();
    audioUrlController.dispose();
    pdfUrlController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> saveBook() async {
    // Implement the logic to save the book details
    // You can access the values from the controllers, e.g., bookIdController.text
    String bookId = bookIdController.text;
    String bookTitleEn = bookTitleEnController.text;
    String bookTitleAr = bookTitleArController.text;
    String bookAuthorEn = authorEnController.text;
    String bookAuthorAr = authorArController.text;
    String bookDescribtionEN = descriptionEnController.text;
    String bookDescribtionAR = descriptionArController.text;
    String bookCategory = categoryController.text;
    int bookPrice = int.tryParse(priceController.text) ?? 0;
    String bookImageUrl = imageUrlController.text;
    String bookAudioUrl = audioUrlController.text;
    String bookPdfUrl = pdfUrlController.text;

    if (bookId.isEmpty ||
        bookTitleEn.isEmpty ||
        bookTitleAr.isEmpty ||
        bookAuthorEn.isEmpty ||
        bookAuthorAr.isEmpty ||
        bookDescribtionEN.isEmpty ||
        bookDescribtionAR.isEmpty ||
        bookCategory.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

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
    final Map<String, dynamic> updateData = {
      'ID': bookId,
      'nameEN': bookTitleEn,
      'nameAR': bookTitleAr,
      'authorAR': bookAuthorAr,
      'authorEN': bookAuthorEn,
      'descriptionEN': bookDescribtionEN,
      'descriptionAR': bookDescribtionAR,
      'audio': bookAudioUrl.isEmpty ? null : bookAudioUrl,
      'pdf': bookPdfUrl.isEmpty ? null : bookPdfUrl,
      'image': bookImageUrl.isEmpty ? null : bookImageUrl,
      'price': bookPrice,
      'category': bookCategory,
    };
    try {
      final query = await FirebaseFirestore.instance
          .collection('books')
          .where('ID', isEqualTo: directBook.bookId)
          .get();

      for (final doc in query.docs) {
        await doc.reference.set(updateData, SetOptions(merge: true));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Book edited successfully')));
    } catch (e, stackTrace) {
      debugPrint('Failed to save book: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save book: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(directBook.bookTitleEn),
        backgroundColor: AppStyles.lightBeige,
      ),
      backgroundColor: AppStyles.pageBackground,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              buildTextField('Book ID', bookIdController, directBook.bookId),
              SizedBox(height: 20),
              buildTextField(
                'Book Title (EN)',
                bookTitleEnController,
                directBook.bookTitleEn,
              ),
              SizedBox(height: 20),

              buildTextField(
                'Book Title (AR)',
                bookTitleArController,
                directBook.bookTitleAr,
              ),
              SizedBox(height: 20),

              buildTextField(
                'Author (EN)',
                authorEnController,
                directBook.bookAuthorEn,
              ),
              SizedBox(height: 20),

              buildTextField(
                'Author (AR)',
                authorArController,
                directBook.bookAuthorAr,
              ),
              SizedBox(height: 20),

              buildTextField(
                'Description (EN)',
                descriptionEnController,
                directBook.bookDescriptionEn,
              ),
              SizedBox(height: 20),

              buildTextField(
                'Description (AR)',
                descriptionArController,
                directBook.bookDescriptionAr,
              ),
              SizedBox(height: 20),

              buildTextField(
                'Category',
                categoryController,
                directBook.bookCategory,
              ),
              SizedBox(height: 20),

              buildTextField(
                'Image URL',
                imageUrlController,
                directBook.bookImageUrl,
              ),
              SizedBox(height: 20),

              buildTextField(
                'Audio URL',
                audioUrlController,
                directBook.bookAudioUrl,
              ),
              SizedBox(height: 20),

              buildTextField(
                'PDF URL',
                pdfUrlController,
                directBook.bookPdfUrl,
              ),
              SizedBox(height: 20),

              buildTextField(
                'Price',
                priceController,
                "${directBook.bookPrice}",
              ),
              SizedBox(height: 20),

              InkWell(
                onTap: () {
                  saveBook();
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.08,
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppStyles.primaryGold,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Save',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildTextField(
    String label,
    TextEditingController controller,
    String fillText,
  ) {
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: BoxBorder.all(color: AppStyles.primaryGold.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(3, 3), // changes position of shadow
          ),
        ],
      ),
      child: TextField(
        
        cursorColor: Colors.black87,
        strutStyle: StrutStyle(height: 1.5),
        controller: controller,

        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}
