import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:network_proxy/ui/mobile/frontend/article/article_list.dart';
import 'package:network_proxy/ui/mobile/frontend/home/home_header.dart';
import 'package:network_proxy/ui/mobile/frontend/home/home_history_article_card.dart';

import '../../../../controller/article_notifier.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleNotifier>(
      builder: (context, articleNotifier, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeaderWidget(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 12, top: 12, right: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'History',
                                style: TextStyle(
                                  fontSize: 22, // 字体大小调大一点
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // 设置为黑色字体
                                  fontFamily: 'Rounded', // 使用圆体字体
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // 这里添加点击事件处理逻辑，例如导航到所有文章页面
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArticleHistoryList(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'all',
                                  style: TextStyle(
                                    fontSize: 18, // 设置字体大小
                                    color: Colors.blue, // 设置为蓝色字体以示链接
                                    fontFamily: 'Rounded', // 使用圆体字体
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        StackedCards(),
                        const Padding(
                          padding: EdgeInsets.only(left: 12, top: 12),
                          child: Text(
                            'Insight for you',
                            style: TextStyle(
                              fontSize: 22, // 字体大小调大一点
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // 设置为黑色字体
                              fontFamily: 'Rounded', // 使用圆体字体
                            ),
                          ),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          itemCount: articleNotifier.articles.length,
                          itemBuilder: (context, index) {
                            return SingleCard(article: articleNotifier.articles[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
