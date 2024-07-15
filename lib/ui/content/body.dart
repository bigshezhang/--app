import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:network_proxy/network/components/request_rewrite_manager.dart';
import 'package:network_proxy/network/http/http.dart';
import 'package:network_proxy/network/util/logger.dart';
import 'package:network_proxy/ui/component/encoder.dart';
import 'package:network_proxy/ui/component/json/json_viewer.dart';
import 'package:network_proxy/ui/component/json/theme.dart';
import 'package:network_proxy/ui/component/multi_window.dart';
import 'package:network_proxy/ui/component/utils.dart';
import 'package:network_proxy/ui/desktop/toolbar/setting/request_rewrite.dart';
import 'package:network_proxy/ui/mobile/setting/request_rewrite.dart';
import 'package:network_proxy/utils/lang.dart';
import 'package:network_proxy/utils/num.dart';
import 'package:network_proxy/utils/platform.dart';
import 'package:window_manager/window_manager.dart';

import '../component/json/json_text.dart';

class HttpBodyWidget extends StatefulWidget {
  final HttpMessage? httpMessage;
  final bool inNewWindow; //是否在新窗口打开
  final WindowController? windowController;
  final ScrollController? scrollController;
  final bool hideRequestRewrite; //是否隐藏请求重写

  const HttpBodyWidget(
      {super.key,
      required this.httpMessage,
      this.inNewWindow = false,
      this.windowController,
      this.scrollController,
      this.hideRequestRewrite = false});

  @override
  State<StatefulWidget> createState() {
    return HttpBodyState();
  }
}

class HttpBodyState extends State<HttpBodyWidget> {
  var bodyKey = GlobalKey<_BodyState>();
  int tabIndex = 0;

  AppLocalizations get localizations => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    if (widget.windowController != null) {
      HardwareKeyboard.instance.addHandler(onKeyEvent);
    }
  }

  /// 按键事件
  bool onKeyEvent(KeyEvent event) {
    if ((HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed) &&
        event.logicalKey == LogicalKeyboardKey.keyW) {
      HardwareKeyboard.instance.removeHandler(onKeyEvent);
      widget.windowController?.close();
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(onKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.httpMessage?.body == null || widget.httpMessage?.body?.isEmpty == true) &&
        widget.httpMessage?.messages.isNotEmpty == false) {
      return const SizedBox();
    }

    var tabs = Tabs.of(widget.httpMessage?.contentType);

    if (tabIndex >= tabs.list.length) tabIndex = tabs.list.length - 1;
    bodyKey.currentState?.changeState(widget.httpMessage, tabs.list[tabIndex]);

    List<Widget> list = [
      widget.inNewWindow ? const SizedBox() : titleWidget(),
      const SizedBox(height: 3),
      SizedBox(
          height: 36,
          child: TabBar(
              labelPadding: const EdgeInsets.only(left: 3, right: 5),
              tabs: tabs.tabList(),
              onTap: (index) {
                tabIndex = index;
                bodyKey.currentState?.changeState(widget.httpMessage, tabs.list[tabIndex]);
              })),
      Padding(
          padding: const EdgeInsets.all(10),
          child: _Body(
              key: bodyKey,
              message: widget.httpMessage,
              viewType: tabs.list[tabIndex],
              scrollController: widget.scrollController)) //body
    ];

    var tabController = DefaultTabController(
        initialIndex: tabIndex,
        length: tabs.list.length,
        child: widget.inNewWindow
            ? ListView(children: list)
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: list));

    if (widget.inNewWindow) {
      return Scaffold(
          appBar: AppBar(title: titleWidget(inNewWindow: true), toolbarHeight: Platform.isWindows ? 36 : null),
          body: tabController);
    }
    return tabController;
  }

  /// 标题
  Widget titleWidget({inNewWindow = false}) {
    var type = widget.httpMessage is HttpRequest ? "Request" : "Response";

    var list = [
      Text('$type Body', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(width: 10),
      IconButton(
          icon: const Icon(Icons.copy, size: 18),
          tooltip: localizations.copy,
          onPressed: () {
            var body = bodyKey.currentState?.body;
            if (body == null) {
              return;
            }
            Clipboard.setData(ClipboardData(text: body))
                .then((value) => FlutterToastr.show(localizations.copied, context));
          }),
    ];

    if (!widget.hideRequestRewrite) {
      list.add(const SizedBox(width: 3));
      list.add(IconButton(
          icon: const Icon(Icons.edit_document, size: 18),
          tooltip: localizations.requestRewrite,
          onPressed: showRequestRewrite));
    }

    list.add(const SizedBox(width: 3));
    list.add(IconButton(
        icon: const Icon(Icons.abc, size: 20),
        tooltip: localizations.encode,
        onPressed: () {
          encodeWindow(EncoderType.base64, context, bodyKey.currentState?.body);
        }));
    if (!inNewWindow) {
      list.add(const SizedBox(width: 3));
      list.add(IconButton(
          icon: const Icon(Icons.open_in_new, size: 18), tooltip: localizations.newWindow, onPressed: () => openNew()));
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: list,
    );
  }

  //展示请求重写
  showRequestRewrite() async {
    HttpRequest? request;
    bool isRequest = widget.httpMessage is HttpRequest;
    if (widget.httpMessage is HttpRequest) {
      request = widget.httpMessage as HttpRequest;
    } else {
      request = (widget.httpMessage as HttpResponse).request;
    }
    var requestRewrites = await RequestRewrites.instance;

    var ruleType = isRequest ? RuleType.requestReplace : RuleType.responseReplace;
    var url = '${request?.remoteDomain()}${request?.path()}';
    var rule = requestRewrites.rules
        .firstWhere((it) => it.matchUrl(url, ruleType), orElse: () => RequestRewriteRule(type: ruleType, url: url));

    var body = bodyKey.currentState?.body;

    var rewriteItems = await requestRewrites.getRewriteItems(rule);
    RewriteType rewriteType = isRequest ? RewriteType.replaceRequestBody : RewriteType.replaceResponseBody;
    if (!rewriteItems.any((element) => element.type == rewriteType)) {
      rewriteItems.add(RewriteItem(rewriteType, true, values: {'body': body}));
    }

    if (!mounted) return;

    if (Platforms.isMobile()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => RewriteRule(rule: rule, items: rewriteItems)));
    } else {
      showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  RuleAddDialog(rule: rule, items: rewriteItems, windowId: widget.windowController?.windowId))
          .then((value) {
        if (value is RequestRewriteRule) {
          FlutterToastr.show(localizations.saveSuccess, context);
        }
      });
    }
  }

  void openNew() async {
    if (Platforms.isDesktop()) {
      var size = MediaQuery.of(context).size;
      var ratio = 1.0;
      if (Platform.isWindows) {
        ratio = WindowManager.instance.getDevicePixelRatio();
      }
      final window = await DesktopMultiWindow.createWindow(jsonEncode(
        {'name': 'HttpBodyWidget', 'httpMessage': widget.httpMessage, 'inNewWindow': true},
      ));
      window
        ..setTitle(widget.httpMessage is HttpRequest ? localizations.requestBody : localizations.responseBody)
        ..setFrame(const Offset(100, 100) & Size(800 * ratio, size.height * ratio))
        ..center()
        ..show();
      return;
    }

    Navigator.push(
        context, MaterialPageRoute(builder: (_) => HttpBodyWidget(httpMessage: widget.httpMessage, inNewWindow: true)));
  }
}

class _Body extends StatefulWidget {
  final HttpMessage? message;
  final ViewType viewType;
  final ScrollController? scrollController;

  const _Body({super.key, this.message, required this.viewType, this.scrollController});

  @override
  State<StatefulWidget> createState() {
    return _BodyState();
  }
}

class _BodyState extends State<_Body> {
  late ViewType viewType;
  HttpMessage? message;

  @override
  void initState() {
    super.initState();
    viewType = widget.viewType;
    message = widget.message;
  }

  changeState(HttpMessage? message, ViewType viewType) {
    setState(() {
      this.message = message;
      this.viewType = viewType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _getBody(viewType);
  }

  String? get body {
    if (message?.isWebSocket == true) {
      return message?.messages.map((e) => e.payloadDataAsString).join("\n");
    }

    if (message == null || message?.body == null) {
      return null;
    }

    if (viewType == ViewType.hex) {
      return message!.body!.map(intToHex).join(" ");
    }
    try {
      if (viewType == ViewType.formUrl) {
        return Uri.decodeFull(message!.bodyAsString);
      }
      if (viewType == ViewType.jsonText || viewType == ViewType.json) {
        //json格式化
        var jsonObject = json.decode(message!.bodyAsString);
        return const JsonEncoder.withIndent("  ").convert(jsonObject);
      }
    } catch (_) {}
    return message!.bodyAsString;
  }

  Widget _getBody(ViewType type) {
    if (message?.isWebSocket == true) {
      List<Widget>? list = message?.messages
          .map((e) => Container(
              margin: const EdgeInsets.only(top: 2, bottom: 2),
              child: Row(
                children: [
                  Expanded(child: Text(e.payloadDataAsString)),
                  const SizedBox(width: 5),
                  SizedBox(
                      width: 130,
                      child: SelectionContainer.disabled(
                          child: Text(e.time.format(), style: const TextStyle(fontSize: 12, color: Colors.grey))))
                ],
              )))
          .toList();
      return Column(
        children: [
          const SelectionContainer.disabled(
              child: Row(children: [
            Expanded(child: Text("Data")),
            SizedBox(width: 130, child: Text("Time")),
          ])),
          Divider(height: 5, thickness: 1, color: Colors.grey[300]),
          ...list ?? []
        ],
      );
    }

    if (message == null || message?.body == null) {
      return const SizedBox();
    }

    try {
      if (type == ViewType.jsonText) {
        var jsonObject = json.decode(message!.bodyAsString);
        return JsonText(
            json: jsonObject,
            indent: Platforms.isDesktop() ? '    ' : '  ',
            colorTheme: ColorTheme.of(Theme.of(context).brightness),
            scrollController: widget.scrollController);
      }

      if (type == ViewType.json) {
        return JsonViewer(json.decode(message!.bodyAsString), colorTheme: ColorTheme.of(Theme.of(context).brightness));
      }

      if (type == ViewType.formUrl) {
        return SelectableText(Uri.decodeFull(message!.bodyAsString), contextMenuBuilder: contextMenu);
      }
      if (type == ViewType.image) {
        return Image.memory(Uint8List.fromList(message?.body ?? []), fit: BoxFit.none);
      }
      if (type == ViewType.hex) {
        return SelectableText(message!.body!.map(intToHex).join(" "), contextMenuBuilder: contextMenu);
      }
    } catch (e) {
      // ignore: avoid_print
      logger.e(e, stackTrace: StackTrace.current);
    }

    return SelectableText.rich(TextSpan(text: message?.bodyAsString), contextMenuBuilder: contextMenu);
  }
}

class Tabs {
  final List<ViewType> list = [];

  static Tabs of(ContentType? contentType) {
    var tabs = Tabs();
    if (contentType == null) {
      return tabs;
    }

    if (contentType == ContentType.json) {
      tabs.list.add(ViewType.jsonText);
    }

    tabs.list.add(ViewType.of(contentType) ?? ViewType.text);

    if (contentType == ContentType.text) {
      tabs.list.add(ViewType.jsonText);
    }
    if (contentType == ContentType.formUrl || contentType == ContentType.json) {
      tabs.list.add(ViewType.text);
    }

    tabs.list.add(ViewType.hex);
    return tabs;
  }

  List<Tab> tabList() {
    return list.map((e) => Tab(child: Text(e.title, style: const TextStyle(fontSize: 14)))).toList();
  }
}

enum ViewType {
  text("Text"),
  formUrl("URL Decode"),
  json("JSON"),
  jsonText("JSON Text"),
  html("HTML"),
  image("Image"),
  css("CSS"),
  js("JavaScript"),
  hex("Hex"),
  ;

  final String title;

  const ViewType(this.title);

  static ViewType? of(ContentType contentType) {
    for (var value in values) {
      if (value.name == contentType.name) {
        return value;
      }
    }
    return null;
  }
}
