import 'package:bayt_alhikma_dashboard/screens/book/webView.dart';
import 'package:bayt_alhikma_dashboard/view_model/LLM_call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../utils/styles.dart';

class addBook extends StatefulWidget {
  const addBook({super.key});

  @override
  State<addBook> createState() => _addBookState();
}

class _addBookState extends State<addBook> {
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

    try {
      await FirebaseFirestore.instance.collection('books').add({
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
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Book added successfully')));
    } catch (e, stackTrace) {
      debugPrint('Failed to save book: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save book: $e')));
    }
  }


  void onGenerateDescriptionPressed(String lang) async {
    // التأكد من أن المستخدم أدخل اسم الكتاب والكاتب أولاً
    if (bookTitleEnController.text.isEmpty || authorEnController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Book Title and Author first!'),
        ),
      );
      return;
    }

    // إظهار مؤشر تحميل (Loading) للمستخدم
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating description with AI...')),
    );
    String? generatedDescription;
    if (lang == "AR") {
      generatedDescription = await generateBookDescription(
        bookTitle: bookTitleArController.text,
        authorName: authorArController.text,
        language: 'Arabic',
      );
    } else {
      generatedDescription = await generateBookDescription(
        bookTitle: bookTitleEnController.text,
        authorName: authorEnController.text,
        language: 'English',
      );
    }

    // إذا نجح التوليد، نضع النص داخل الـ Controller الخاص بالوصف
    if (generatedDescription != null) {
      setState(() {
        if(lang=="AR"){
          descriptionArController.text = generatedDescription ?? "";
        
        }else{
          descriptionEnController.text = generatedDescription ?? "";
        }
        
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate description.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.pageBackground,
      appBar: AppBar(
        title: const Text('Add Book'),
        backgroundColor: AppStyles.lightBeige,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              buildTextField('Book ID', bookIdController),
              SizedBox(height: 20),
              buildTextField('Book Title (EN)', bookTitleEnController),
              SizedBox(height: 20),

              buildTextField('Book Title (AR)', bookTitleArController),
              SizedBox(height: 20),

              buildTextField('Author (EN)', authorEnController),
              SizedBox(height: 20),

              buildTextField('Author (AR)', authorArController),
              SizedBox(height: 20),

              SpecialTextFieldWidget(
                label: "Description (EN)",
                controller: descriptionEnController,
                langFlag: 'EN',
                onGenerateDescriptionPressed: onGenerateDescriptionPressed,
              ),
              SizedBox(height: 20),

              SpecialTextFieldWidget(
                label: 'Description (AR)',
                controller: descriptionArController,
                langFlag: 'AR',
                onGenerateDescriptionPressed: onGenerateDescriptionPressed,
              ),
              SizedBox(height: 20),

              buildTextField('Category', categoryController),
              SizedBox(height: 20),

              // buildTextField('Image URL', imageUrlController),
              ImageSearchFieldWidget(
                controller: imageUrlController,
                titleEnController: bookTitleEnController,
                titleArController: bookTitleArController,
              ),
              SizedBox(height: 20),

              buildTextField('Audio URL', audioUrlController),
              SizedBox(height: 20),

              buildTextField('PDF URL', pdfUrlController),
              SizedBox(height: 20),

              buildTextField('Price', priceController),
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
                      'Add',
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

  Container buildTextField(String label, TextEditingController controller) {
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
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class SpecialTextFieldWidget extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String langFlag;
  final Function(String lang) onGenerateDescriptionPressed;
  const SpecialTextFieldWidget({
    Key? key,
    required this.label,
    required this.controller,
    required this.langFlag,
    required this.onGenerateDescriptionPressed,
  }) : super(key: key);

  @override
  State<SpecialTextFieldWidget> createState() => _SpecialTextFieldWidgetState();
}

class _SpecialTextFieldWidgetState extends State<SpecialTextFieldWidget> {
  // إنشاء FocusNode لمراقبة حالة التركيز (الضغط)
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    // إضافة مستمع للـ FocusNode لتحديث واجهة المستخدم عند التغيير
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // يجب التخلص من الـ FocusNode لتجنب تسريب الذاكرة (Memory Leak)
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppStyles.primaryGold.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: TextField(
        focusNode: _focusNode, // ربط الـ FocusNode بحقل النص
        cursorColor: Colors.black87,
        strutStyle: const StrutStyle(height: 1.5),
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black54),

          // شرط: إذا كان الحقل مضغوطاً عليه (_isFocused = true) اعرض الزر، وإلا اجعله null
          suffixIcon: _isFocused
              ? InkWell(
                  splashColor: AppStyles.primaryGold,
                  focusColor: AppStyles.primaryGold,
                  radius: 5.0,
                  onTap: () {
                    widget.onGenerateDescriptionPressed(widget.langFlag);
                  },
                  child: Column(
                    children: [
                      Icon(Icons.bolt, color: AppStyles.primaryGold),
                      Text(
                        'AI',
                        style: TextStyle(color: AppStyles.primaryGold),
                      ),
                    ],
                  ),
                )
              : null,

          border: InputBorder.none,
        ),
      ),
    );
  }
  
}
class ImageSearchFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController titleEnController;
  final TextEditingController titleArController;

  const ImageSearchFieldWidget({
    Key? key,
    required this.controller,
    required this.titleEnController,
    required this.titleArController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppStyles.primaryGold.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: TextField(
        cursorColor: Colors.black87,
        strutStyle: const StrutStyle(height: 1.5),
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Image URL',
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black54),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.image_search, color: AppStyles.primaryGold),
            onPressed: () {
              // نأخذ اسم الكتاب بالعربي أو بالإنجليزي للبحث عنه
              String bookName = titleArController.text.isNotEmpty
                  ? titleArController.text
                  : titleEnController.text;

              if (bookName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter Book Title first!')),
                );
                return;
              }

              // فتح شاشة البحث وتمرير الرابط المنسوخ إلى הـ Controller
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoogleImageSearchScreen(
                    bookName: bookName,
                    onLinkCopied: (url) {
                      controller.text = url; // هذه الخطوة تملأ النص مباشرة
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
