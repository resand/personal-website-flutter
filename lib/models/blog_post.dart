class BlogPost {
  final String title;
  final String description;
  final String url;
  final DateTime publishedDate;
  final String? imageUrl;
  final List<String> categories;
  final String author;
  final int readTimeMinutes;
  final String source; // New property to identify the source

  BlogPost({
    required this.title,
    required this.description,
    required this.url,
    required this.publishedDate,
    this.imageUrl,
    required this.categories,
    required this.author,
    required this.readTimeMinutes,
    this.source = 'Medium', // Default value to maintain compatibility
  });



  String getFormattedDate(List<String> monthNames) {
    return '${monthNames[publishedDate.month - 1]} ${publishedDate.day}, ${publishedDate.year}';
  }

  String getReadTimeText(String minReadText) {
    return '$readTimeMinutes $minReadText';
  }
}