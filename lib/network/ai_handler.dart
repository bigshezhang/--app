import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AiHandler {
  final String apiUrl = 'https://api.siliconflow.cn/v1/chat/completions';
  final String apiToken = 'sk-zzmsmzaecxwpucyffoqpgkqohxxcqdhcislcgyvappxdrujq';
  final whitelistFilePath = 'assets/whitelist.json';
  late List<String> whitelist;

  static final AiHandler _instance = AiHandler._internal();

  factory AiHandler({String whitelistFilePath = 'assets/whitelist.json'}) {
    _instance._loadWhitelist(whitelistFilePath);
    return _instance;
  }

  AiHandler._internal();

  late String _apiUrl;
  late String _apiToken;

  void _loadWhitelist(String filePath) async {
    final jsonString = await rootBundle.loadString(filePath);
    final jsonData = jsonDecode(jsonString);
    whitelist = List<String>.from(jsonData['whitelist']);
  }

  Future<String> summarizeText(String inputText) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiToken',
      },
      body: jsonEncode({
        'model': 'deepseek-ai/DeepSeek-V2-Chat',
        'messages': [
          {
            'role': 'user',
            'content': '请总结以下内容：$inputText',
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

  bool isUrlInWhitelist(String url) {
    print("白名单是：$whitelist");

    for (String entry in whitelist) {
      if (url.contains(entry)) {
        return true;
      }
    }
    return false;
  }
}
