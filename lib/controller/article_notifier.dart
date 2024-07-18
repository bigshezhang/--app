import 'package:flutter/material.dart';
import 'package:network_proxy/controller/database_helper.dart';
import 'package:network_proxy/model/article_model.dart';

class ArticleNotifier extends ChangeNotifier {
  List<Article> _articles = [];

  ArticleNotifier() {
    init();
  }

  void init() async {
    _articles = await DatabaseHelper.instance.readLatestThreeArticles();
    print("Stack 文章数量：$_articles");
    notifyListeners(); // 确保在数据加载完成后通知监听者
  }

  List<Article> get articles => _articles;

  void addArticle(Article article) {
    _articles.add(article);
    if(_articles.length > 2){
      _articles.removeAt(0);
    }
    print("已通知更新");
    notifyListeners();
  }

  void setArticles(List<Article> articles) {
    _articles = articles;
    if(_articles.length > 2){
      _articles.removeAt(0);
    }
    notifyListeners();
  }
}
