import 'package:flutter/material.dart';
import 'package:network_proxy/controller/article_notifier.dart';
import 'package:provider/provider.dart';

import '../../../../model/article_model.dart';
import '../home/home_history_article_card.dart';

class ArticleHistoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleNotifier>(
        builder: (context, articleNotifier, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                      ),
                    ),
                    padding: EdgeInsets.only(top: 48,left: 24),
                    child:
                    Text("History",style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold,)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      itemCount: articleNotifier.articles.length,
                      itemBuilder: (context, index) {
                        return SingleCard(article: articleNotifier.articles[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
