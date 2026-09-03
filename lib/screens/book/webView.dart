import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';

class GoogleImageSearchScreen extends StatefulWidget {
  final String bookName;
  final Function(String) onLinkCopied;

  const GoogleImageSearchScreen({
    Key? key,
    required this.bookName,
    required this.onLinkCopied,
  }) : super(key: key);

  @override
  State<GoogleImageSearchScreen> createState() => _GoogleImageSearchScreenState();
}

class _GoogleImageSearchScreenState extends State<GoogleImageSearchScreen> {
  double progress = 0; // متغير لتتبع نسبة التحميل

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image search: ${widget.bookName}'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('https://www.google.com/search?tbm=isch&q=${Uri.encodeComponent(widget.bookName)}'),
            ),
            // تفعيل JavaScript وإعدادات المتصفح الأساسية
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              transparentBackground: true,
            ),
            // تتبع نسبة التحميل
            onProgressChanged: (controller, progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
            // طباعة الخطأ في الكونسول إذا فشل التحميل
            onLoadError: (controller, url, code, message) {
              debugPrint("WebView Error: $message");
            },
            // التقاط الضغط المطول
            onLongPressHitTestResult: (controller, hitTestResult) async {
              if (hitTestResult.type == InAppWebViewHitTestResultType.IMAGE_TYPE ||
                  hitTestResult.type == InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE) {
                String? imageUrl = hitTestResult.extra;
                if (imageUrl != null && imageUrl.isNotEmpty) {
                  _showImageOptions(context, imageUrl);
                }
              }
            },
          ),
          
          // عرض شريط تحميل أعلى المتصفح يختفي عند اكتمال التحميل
          if (progress < 1.0)
            LinearProgressIndicator(value: progress, color: Colors.blue),
        ],
      ),
    );
  }

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
                title: const Text('حفظ الصورة في الجهاز'),
                onTap: () {
                  Navigator.pop(ctx);
                  _saveImage(context, imageUrl);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('نسخ مباشر للرابط'),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onLinkCopied(imageUrl);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveImage(BuildContext context, String url) async {
    try {
      if (url.startsWith('data:image')) {
  String base64String = url.split(',').last;
  Uint8List bytes = base64Decode(base64String);
  await Gal.putImageBytes(bytes);
} else {
  var response = await Dio().get(
      url, options: Options(responseType: ResponseType.bytes));
  await Gal.putImageBytes(Uint8List.fromList(response.data));
}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحفظ بنجاح')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء الحفظ')));
    }
  }
}