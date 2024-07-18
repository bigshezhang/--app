import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../controller/proxy_server_provider.dart';
import '../../../../native/vpn.dart';
import '../../../../utils/ip.dart';
import '../../../launch/launch.dart';

class HomeHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final proxyServer = Provider.of<ProxyServerProvider>(context).proxyServer;

    return Container(
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50), // 适当的上边距
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '寂记',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 4),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                Center(
                    child: SocketLaunch(
                        proxyServer: proxyServer,
                        size: 36,
                        startup: proxyServer.configuration.startup,
                        serverLaunch: false,
                        onStart: () async {
                          Vpn.startVpn(
                              Platform.isAndroid ? await localIp() : "127.0.0.1", proxyServer.port, proxyServer.configuration);
                        },
                        onStop: () => Vpn.stopVpn()))
                // Row(
                //   children: [
                //     Icon(Icons.diamond, color: Colors.blue, size: 16),
                //     SizedBox(width: 5),
                //     Text(
                //       '运行中',
                //       style: TextStyle(color: Colors.white),
                //     ),
                //   ],
                // ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            ' 所见，亦所记',
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Type to Search',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}