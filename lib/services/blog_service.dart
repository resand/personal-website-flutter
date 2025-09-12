import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/blog_post.dart';
import '../models/website_config.dart';

class BlogService {
  static const String _rss2JsonUrl = 'https://api.rss2json.com/v1/api.json?rss_url=';
  
  static Future<List<BlogPost>> fetchAllPosts(BlogConfig blogConfig) async {
    final allPosts = <BlogPost>[];
    
    for (final source in blogConfig.sources.where((s) => s.enabled)) {
      try {
        final posts = await _fetchPostsFromSource(source, blogConfig.maxPostsToShow);
        allPosts.addAll(posts);
      } catch (e) {
        // Skip source on error
      }
    }
    
    // Sort by date (most recent first) and limit
    allPosts.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
    return allPosts.take(blogConfig.maxPostsToShow).toList();
  }
  
  static Future<List<BlogPost>> _fetchPostsFromSource(BlogSource source, int maxPosts) async {
    try {
      final apiUrl = '$_rss2JsonUrl${source.rssUrl}';
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'ok' && data.containsKey('items')) {
          final items = data['items'] as List;
          
          final posts = items
              .take(maxPosts)
              .map((item) => _parseRss2JsonItem(item, source.name))
              .where((post) => post != null)
              .cast<BlogPost>()
              .toList();
          
          if (posts.isNotEmpty) {
            return posts;
          }
        }
      }
      
    } catch (e) {
      // Skip source on error
    }
    
    return <BlogPost>[];
  }
  

  static BlogPost? _parseRss2JsonItem(Map<String, dynamic> item, String sourceName) {
    try {
      final title = item['title'] as String? ?? '';
      final description = item['description'] as String? ?? '';
      final link = item['link'] as String? ?? '';
      final pubDate = item['pubDate'] as String? ?? '';
      final author = item['author'] as String? ?? '';
      final thumbnail = item['thumbnail'] as String?;
      final categories = (item['categories'] as List?)?.cast<String>() ?? <String>[];
      
      if (title.isEmpty || link.isEmpty) {
        return null;
      }

      return BlogPost(
        title: _cleanHtml(title),
        description: _cleanHtml(description),
        url: link,
        publishedDate: _parseDate(pubDate),
        imageUrl: thumbnail?.isNotEmpty == true ? thumbnail : null,
        categories: categories,
        author: _cleanHtml(author),
        readTimeMinutes: _calculateReadTime(description),
        source: sourceName,
      );
    } catch (e) {
      return null;
    }
  }

  static String _cleanHtml(String html) {
    if (html.isEmpty) return '';
    
    String cleaned = html;
    
    // Handle CDATA sections first (extract content)
    final cdataRegex = RegExp(r'<!\[CDATA\[(.*?)\]\]>', dotAll: true);
    final cdataMatch = cdataRegex.firstMatch(cleaned);
    if (cdataMatch != null) {
      cleaned = cdataMatch.group(1) ?? '';
    }
    
    // Then clean HTML tags
    cleaned = cleaned
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
        
    return cleaned;
  }

  static DateTime _parseDate(String dateString) {
    if (dateString.isEmpty) return DateTime.now();
    
    try {
      // Clean the date string
      String cleanDate = dateString.trim();
      
      // Handle RFC 2822 format (e.g., "Thu, 13 Jun 2024 19:54:23 GMT")
      if (cleanDate.contains(',')) {
        final parts = cleanDate.split(',');
        if (parts.length == 2) {
          cleanDate = parts[1].trim();
        }
      }
      
      // Try parsing standard ISO format first
      final parsed = DateTime.tryParse(cleanDate);
      if (parsed != null) return parsed;
      
      // Try parsing with different formats for RSS dates
      final formats = [
        // Common RSS formats
        cleanDate.replaceAll('GMT', '').replaceAll('UTC', '').trim(),
        cleanDate.replaceAll(RegExp(r'\s+(GMT|UTC|EST|PST|CST|MST)\s*$'), ''),
      ];
      
      for (final format in formats) {
        final result = DateTime.tryParse(format);
        if (result != null) return result;
      }
      
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  static int _calculateReadTime(String content) {
    final cleanContent = _cleanHtml(content);
    final wordCount = cleanContent.split(' ').length;
    final readTimeMinutes = (wordCount / 200).ceil();
    return readTimeMinutes < 1 ? 1 : readTimeMinutes;
  }

}