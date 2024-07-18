import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network_proxy/controller/database_helper.dart';
import 'package:network_proxy/native/pip.dart';
import 'package:network_proxy/ui/mobile/frontend/home/home_header.dart';
import 'package:network_proxy/ui/mobile/frontend/home/home_history_article_card.dart';
import 'dart:async';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    const Padding(
                        padding: EdgeInsets.only(left: 12,top: 12),
                      child: Text(
                        'History',
                        style: TextStyle(
                          fontSize: 22, // 字体大小调大一点
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // 设置为黑色字体
                          fontFamily: 'Rounded', // 使用圆体字体
                        ),
                      ),
                    ),
                    StackedCards(),
                    const Padding(
                      padding: EdgeInsets.only(left: 12,top: 12),
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
                    FloatingActionButton(
                      child: Text("Click"),
                        onPressed: ()=> {
                          // DatabaseHelper.instance.clearAllArticles()
                        }
                    )
                  ]
                )
              )
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.white,
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.search),
      //       label: 'Search',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.photo_camera),
      //       label: 'Scan',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      //   selectedItemColor: Colors.green,
      // ),
    );
  }
}
