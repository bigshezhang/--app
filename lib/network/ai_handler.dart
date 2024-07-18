import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:network_proxy/model/article_model.dart';
import 'package:network_proxy/network/extract_content_handler.dart';
import 'package:uuid/uuid.dart';

import '../native/pip.dart';
import '../controller/database_helper.dart';

class AiHandler {
  final String apiUrl = 'https://api.siliconflow.cn/v1/chat/completions';
  final String apiToken = 'sk-zzmsmzaecxwpucyffoqpgkqohxxcqdhcislcgyvappxdrujq';
  final whitelistFilePath = 'assets/whitelist.json';
  late List<String> whitelist;

  static final AiHandler _instance = AiHandler._internal();

  factory AiHandler() {
    _instance._loadWhitelist('assets/whitelist.json');
    return _instance;
  }

  AiHandler._internal();
  final extractContentHandler = ExtractContentHandler();


  void _loadWhitelist(String filePath) async {
    final jsonString = await rootBundle.loadString(filePath);
    final jsonData = jsonDecode(jsonString);
    whitelist = List<String>.from(jsonData['whitelist']);
  }

  /// 对未处理 response 进行提取并总结
  void summarizeHandler(String matchedURI, String msg) async {
    Map articleInfo = {};
    articleInfo = await extractContentHandler.extractContent(matchedURI, msg);
    articleInfo["summarizedContent"] = await summarizeText(articleInfo['content'], articleInfo["prompt"]);
    print(articleInfo["summarizedContent"]);
    var article_object = Article(
        title: articleInfo["title"],
        content: articleInfo["content"],
        prompt: articleInfo["prompt"],
        summarizedContent: articleInfo["summarizedContent"],
        timestamp: DateTime.now().toString());

    await DatabaseHelper.instance.create(article_object);

    PictureInPicture.changeData(articleInfo["summarizedContent"]);
  }
  
  /// 对文字进行总结的执行器
  Future<String> summarizeText(String inputText, String prompt) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiToken',
      },
      body: jsonEncode({
        'model': 'deepseek-ai/DeepSeek-V2-Chat',
        'messages': [
          {
            'role': 'user',
            'content': '$prompt\n$inputText',
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? '总结内容为空';
    } else {
      throw Exception('API 请求失败，状态码：${response.statusCode}');
    }
  }

  String? checkUrlInWhitelist(String url) {
    for (String entry in whitelist) {
      if (url.contains(entry)) {
        return entry;
      }
    }
    return null;
  }
}
