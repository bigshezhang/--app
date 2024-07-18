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

  Future<Map> extractContent(String matchedURI, String msg) async {
    var selfExtractConfig = extractConfig[matchedURI];
    print("策略是：$selfExtractConfig");
    switch (selfExtractConfig["type"]) {
      case 'text':
        return extractHTMLContent(selfExtractConfig, msg);
      case 'json':
        return extractJSONContent(selfExtractConfig, msg);
      default:
        /// FIXME 解决这个可能为空的返回
        return extractHTMLContent(selfExtractConfig, msg);
    }
  }

  Future<Map> extractHTMLContent(Map selfExtractConfig, String msg) async {
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

    Map articleInfo = {"title" : extractedTitle, "content" : extractedContent};
    articleInfo["prompt"] = selfExtractConfig["prompt"];
    // print("标题：$extractedTitle");
    // print("正文： $extractedContent");
    return articleInfo;
  }

  Future<Map<String, dynamic>> extractJSONContent(Map<String, dynamic> selfExtractConfig, String jsonResponse) async {
    print("开始 JSON 提取");

    final pathToTitle = selfExtractConfig["path_to_title"] == "" ? "" : selfExtractConfig["path_to_title"].split('.');
    final pathToContent = selfExtractConfig["path_to_content"].split('.');
    final defaultContent = selfExtractConfig["default_content"];

    dynamic jsonData;
    try {
      jsonData = jsonDecode(jsonResponse);
    } catch (e) {
      throw FormatException("Invalid JSON format: $e");
    }

    dynamic extractedTitle = jsonData;

    if (pathToTitle != ""){
      try {
        for (final key in pathToTitle) {
          if (key.contains('[') && key.contains(']')) {
            // 处理数组索引
            final parts = key.split(RegExp(r'\[|\]'));
            final arrayKey = parts[0];
            final index = int.parse(parts[1]);
            extractedTitle = extractedTitle[arrayKey][index];
          } else {
            extractedTitle = extractedTitle[key];
          }

          if (extractedTitle == null) {
            extractedTitle = defaultContent;
            break;
          }
        }
      } catch (e) {
        extractedTitle = defaultContent;
      }
    } else {
      extractedTitle = "无标题";
    }

    dynamic extractedContent = jsonData;

    try {
      for (final key in pathToContent) {
        if (key.contains('[') && key.contains(']')) {
          // 处理数组索引
          final parts = key.split(RegExp(r'\[|\]'));
          final arrayKey = parts[0];
          final index = int.parse(parts[1]);
          extractedContent = extractedContent[arrayKey][index];
        } else {
          extractedContent = extractedContent[key];
        }

        if (extractedContent == null) {
          extractedContent = defaultContent;
          break;
        }
      }
    } catch (e) {
      extractedContent = defaultContent;
    }
    print("文章标题：$extractedTitle \n文章内容：$extractedContent");
    return {
      "title": extractedTitle,
      "content": extractedContent,
      "prompt": selfExtractConfig["prompt"]
    };
  }

  void _loadExtractConfig(String filePath) async {
    final jsonString = await rootBundle.loadString(filePath);
    final jsonData = jsonDecode(jsonString);
    extractConfig = jsonData["extract_config"];
    //print("提取策略: $extractConfig");
  }
}