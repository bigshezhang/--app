import 'package:flutter/material.dart';
import 'package:network_proxy/network/bin/configuration.dart';

import '../network/bin/server.dart';

class ProxyServerProvider with ChangeNotifier {
  ProxyServer proxyServer = ProxyServer(Configuration.instance);

  void init() async {
    // Initialize the ProxyServer instance
    print("proxy初始化");
  }

// You can add more methods here to interact with proxyServer
}

ProxyServerProvider proxyServerProvider = ProxyServerProvider();