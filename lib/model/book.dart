class Book {
  final String bookId;
  final String bookTitleEn;
  final String bookTitleAr;
  final String bookAuthorEn;
  final String bookAuthorAr;
  final String bookDescriptionEn;
  final String bookDescriptionAr;
  final String bookCategory;
  final int bookPrice;
  final String bookImageUrl;
  final String bookAudioUrl;
  final String bookPdfUrl;

  Book({
    required this.bookId,
    required this.bookTitleEn,
    required this.bookTitleAr,
    required this.bookAuthorEn,
    required this.bookAuthorAr,
    required this.bookDescriptionEn,
    required this.bookDescriptionAr,
    required this.bookCategory,
    required this.bookPrice,
    required this.bookImageUrl,
    required this.bookAudioUrl,
    required this.bookPdfUrl,
  });
}
