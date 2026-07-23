import 'package:bayt_alhikma_dashboard/model/book.dart';
import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
    bookIdController = TextEditingController();
    bookTitleEnController = TextEditingController();
    bookTitleArController = TextEditingController();
    authorEnController = TextEditingController();
    authorArController = TextEditingController();
    descriptionEnController = TextEditingController();
    descriptionArController = TextEditingController();
    categoryController = TextEditingController();
    imageUrlController = TextEditingController();
    audioUrlController = TextEditingController();
    pdfUrlController = TextEditingController();
    priceController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
