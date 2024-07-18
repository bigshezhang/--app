import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../model/article_model.dart';
import 'package:flutter_html/flutter_html.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  ArticleDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Article Detail'),
      // ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),

              Text(
                article.summarizedContent,
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.normal),
              ),
              SizedBox(height: 20),
              Text(
                article.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Offstage(
                offstage: article.type == 'text',
                child: Text(
                  article.content,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Offstage(
                offstage: article.type == 'json',
                child: Html(
                  data: article.html,
                )
              )

            ],
          )

        ),
      ),
    );
  }
}
