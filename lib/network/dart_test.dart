import 'dart:io';
import 'package:html/parser.dart' as html_parser;

import 'package:html_main_element/html_main_element.dart';

void main() async {
  // Load and parse html document
  final htmlFile = File('lib/network/test.html');
  final document = html_parser.parse(await htmlFile.readAsBytes());
  // Genererate score map and get score for every html element
  final scoreMapReadability = readabilityScore(document.documentElement!);
  // Get the best scoring html element
  final bestElemReadability = readabilityMainElement(document.documentElement!);
  print(bestElemReadability.text);
}

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';
//
// Future<String> fetchHtmlTitle(String url) async {
//   final response = await http.get(Uri.parse(url));
//
//   if (response.statusCode == 200) {
//     final html = response.body;
//     final titleRegExp = RegExp(r'<title>(.*?)<\/title>', caseSensitive: false);
//     final match = titleRegExp.firstMatch(html);
//     if (match != null) {
//       return match.group(1) ?? 'No title found';
//     } else {
//       return 'No title found';
//     }
//   } else {
//     throw Exception('Failed to load page');
//   }
// }
//
// void main() async {
//   final url = 'https://ios.sspai.com/post/90413?top-height=59.0'; // 替换为您要获取的 URL
//   try {
//     final title = await fetchHtmlTitle(url);
//     print('Title: $title');
//   } catch (e) {
//     print('Error: $e');
//   }
// }
