import 'package:network_proxy/ui/mobile/frontend/article/article_detail.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../../controller/article_notifier.dart';
import '../../../../model/article_model.dart';

class StackedCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleNotifier>(
      builder: (context, articleNotifier, child) {
        return Container(
          height: articleNotifier.articles.length != 0 ? 150 : 0,
          // color: Colors.black,
          // margin: EdgeInsets.symmetric(vertical: 16.0),
          child: Container(
            child:
            Stack(
              children: [
                if (articleNotifier.articles.length > 0)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: SingleCard(article: articleNotifier.articles[articleNotifier.articles.length - 3],),
                  ),
                if (articleNotifier.articles.length > 1)
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: SingleCard(article: articleNotifier.articles[articleNotifier.articles.length - 2],),
                  ),
                if (articleNotifier.articles.length > 2)
                  SingleCard(article: articleNotifier.articles[articleNotifier.articles.length - 1],),
              ],
            ),
          ),
        );
      },
    );
  }
}
class SingleCard extends StatelessWidget {
  final Article article;
  SingleCard({required this.article});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: EdgeInsets.only(top: 6, bottom: 6,right: 6,left: 6),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child:
      InkWell(
        onTap: () {
          // 这里添加点击事件处理逻辑，例如导航到所有文章页面
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ArticleDetailPage(article: article)),
          );
        },
        child: Row(
          children: [
            // Container(
            //   width: 50,
            //   height: 50,
            //   decoration: BoxDecoration(
            //     color: Colors.grey[300],
            //     borderRadius: BorderRadius.circular(8.0),
            //   ),
            // ),
            // SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // 防止文字溢出
                  ),
                  SizedBox(height: 5),
                  Text(article.summarizedContent, style: TextStyle(color: Colors.grey[600]),overflow: TextOverflow.ellipsis,maxLines: 3,),
                  // Row(
                  //   children: [
                  //     Icon(Icons.shield, color: Colors.green, size: 16),
                  //     SizedBox(width: 4),
                  //     Text('Safety 76/100'),
                  //     SizedBox(width: 8),
                  //     Text('Kaolin', style: TextStyle(color: Colors.grey[600])),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      )

    );
  }
}
