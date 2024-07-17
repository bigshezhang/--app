import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser; // 导入 HTML 解析库
import 'package:html/dom.dart'; // 导入 DOM 库
import 'package:html_main_element/html_main_element.dart';
import 'package:html/parser.dart' as html_parser;

class ExtractContentHandler{
  late Map extractConfig;
  static final ExtractContentHandler _instance = ExtractContentHandler._internal();

  factory ExtractContentHandler() {
    _instance._loadExtractConfig('assets/extract_config.json');
    return _instance;
  }

  ExtractContentHandler._internal();

  void extractContent(String matchedURI, String msg){
    var selfExtractConfig = extractConfig[matchedURI];
    print("策略是：$selfExtractConfig");
    switch (selfExtractConfig["type"]) {
      case 'text':
        extractHTMLContent(selfExtractConfig, msg);
      default:
        print('错误，我什么都没找到');
    }
  }

  Future<String?> extractHTMLContent(Map selfExtractConfig, String msg) async {
    print("开始 HTML 提取");
    final extractedTitle;
    final extractedContent;

    final document = html_parser.parse(msg);
    // Genererate score map and get score for every html element
    final scoreMapReadability = readabilityScore(document.documentElement!);
    // Get the best scoring html element

    final bestElemReadability = readabilityMainElement(document.documentElement!);

    final titleRegExp = RegExp(r'<title>(.*?)<\/title>', caseSensitive: false);
    final match = titleRegExp.firstMatch(msg);
    if (match != null) {
      extractedTitle =  match.group(1) ?? 'No title found';
    } else {
      extractedTitle = 'No title found';
    }

    extractedContent = bestElemReadability.text;
    print("标题：$extractedTitle");
    print("正文： $extractedContent");
  }

  void _loadExtractConfig(String filePath) async {
    final jsonString = await rootBundle.loadString(filePath);
    final jsonData = jsonDecode(jsonString);
    extractConfig = jsonData["extract_config"];
    //print("提取策略: $extractConfig");
  }
}