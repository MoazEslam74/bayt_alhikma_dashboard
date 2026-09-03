import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class GoogleImageSearchScreen extends StatelessWidget {
  final String bookName;
  final Function(String) onLinkCopied;

  const GoogleImageSearchScreen({
    Key? key,
    required this.bookName,
    required this.onLinkCopied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image search: $bookName'),
        backgroundColor: Colors.white, // يمكنك استخدام AppStyles.lightBeige
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('https://www.google.com/search?tbm=isch&q=${Uri.encodeComponent(bookName)}'),
        ),
        // التقاط الضغط المطول
        onLongPressHitTestResult: (controller, hitTestResult) async {
          // التحقق مما إذا كان العنصر المضغوط هو صورة
          if (hitTestResult.type == InAppWebViewHitTestResultType.IMAGE_TYPE ||
              hitTestResult.type == InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE) {
            String? imageUrl = hitTestResult.extra;
            if (imageUrl != null && imageUrl.isNotEmpty) {
              _showImageOptions(context, imageUrl);
            }
          }
        },
      ),
    );
  }

  // عرض القائمة السفلية (Bottom Sheet)
  void _showImageOptions(BuildContext context, String imageUrl) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Save Image to Device'),
                onTap: () {
                  Navigator.pop(ctx);
                  _saveImage(context, imageUrl);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Link Directly'),
                onTap: () {
                  Navigator.pop(ctx); // إغلاق القائمة السفلية
                  onLinkCopied(imageUrl); // تمرير الرابط لملء حقل النص
                  Navigator.pop(context); // الرجوع إلى شاشة إضافة الكتاب
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // وظيفة حفظ الصورة في الجهاز
  Future<void> _saveImage(BuildContext context, String url) async {
    try {
      if (url.startsWith('data:image')) {
        // معالجة الصور المصغرة التي تأتي بصيغة Base64
        String base64String = url.split(',').last;
        Uint8List bytes = base64Decode(base64String);
        await ImageGallerySaver.saveImage(bytes, quality: 100);
      } else {
        // معالجة الروابط العادية (http/https)
        var response = await Dio().get(
            url, options: Options(responseType: ResponseType.bytes));
        await ImageGallerySaver.saveImage(
            Uint8List.fromList(response.data), quality: 100);
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while saving the image')));
    }
  }
}