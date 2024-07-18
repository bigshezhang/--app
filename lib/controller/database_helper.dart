import 'package:network_proxy/utils/navigator.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:network_proxy/model/article_model.dart';
import 'package:flutter/material.dart';
import 'article_notifier.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('articles.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE articles (
  id $idType,
  title $textType,
  content $textType,
  prompt $textType,
  summarizedContent $textType,
  timestamp $textType
  )
''');
  }


  Future<Article?> create(Article article) async {
    final db = await instance.database;

    // Check for duplicate content
    final existingArticles = await db.query(
      'articles',
      where: 'content = ?',
      whereArgs: [article.content],
    );

    if (existingArticles.isNotEmpty) {
      print("文章已存在");
      return null;
    }

    print("新建文章中");
    print(article.toString());

    final id = await db.insert('articles', article.toMap());
    final newArticle = article.copy(id: id);

    // Notify the ArticleNotifier
    _notifyArticleNotifier(newArticle);

    return newArticle;
  }

  void _notifyArticleNotifier(Article article) {
    final context = navigatorHelper.navigatorKey.currentContext;
    if (context != null) {
      final articleNotifier = Provider.of<ArticleNotifier>(context, listen: false);
      articleNotifier.addArticle(article);
    }
  }

  Future<List<Article>> readAllArticles() async {
    final db = await instance.database;
    final orderBy = 'timestamp DESC';
    final result = await db.query('articles', orderBy: orderBy);
    print("所有文章 \n$result.toString()");
    return result.map((json) => Article.fromMap(json)).toList();
  }

  Future<List<Article>> readLatestThreeArticles() async {
    final db = await instance.database;
    final orderBy = 'timestamp DESC';
    final limit = 3;
    final result = await db.query('articles', orderBy: orderBy, limit: limit);

    return result.map((json) => Article.fromMap(json)).toList();
  }

  Future<int> update(Article article) async {
    final db = await instance.database;

    return db.update(
      'articles',
      article.toMap(),
      where: 'id = ?',
      whereArgs: [article.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      'articles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllArticles() async {
    final db = await instance.database;
    await db.delete('articles');

    // Notify the ArticleNotifier
    final context = navigatorHelper.navigatorKey.currentContext;
    if (context != null) {
      final articleNotifier = Provider.of<ArticleNotifier>(context, listen: false);
      articleNotifier.setArticles([]);
    }
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
