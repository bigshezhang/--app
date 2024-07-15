import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:network_proxy/network/http/http.dart';

const contentMap = {
  ContentType.json: Icons.data_object,
  ContentType.html: Icons.html,
  ContentType.js: Icons.javascript,
  ContentType.image: Icons.image,
  ContentType.text: Icons.text_fields,
  ContentType.css: Icons.css,
  ContentType.font: Icons.font_download,
};

Icon getIcon(HttpResponse? response) {
  if (response == null) {
    return const Icon(Icons.question_mark, size: 16, color: Colors.green);
  }
  if (response.status.code < 0) {
    return const Icon(Icons.error, size: 16, color: Colors.red);
  }

  var contentType = response.contentType;
  return Icon(contentMap[contentType] ?? Icons.http, size: 16, color: Colors.green);
}

//展示报文大小
String getPackagesSize(HttpRequest request, HttpResponse? response) {
  var package = getPackage(request);
  var responsePackage = getPackage(response);
  if (responsePackage.isEmpty) {
    return package;
  }
  return "$package / $responsePackage ";
}

String getPackage(HttpMessage? message) {
  var size = message?.packageSize;
  if (size == null) {
    return "";
  }
  if (size > 1024 * 1024) {
    return "${(size / 1024 / 1024).toStringAsFixed(2)}M";
  }
  return "${(size / 1024).toStringAsFixed(2)}K";
}

String copyRequest(HttpRequest request, HttpResponse? response) {
  var sb = StringBuffer();
  sb.writeln("Request");
  sb.writeln("${request.method.name} ${request.requestUrl} ${request.protocolVersion}");
  sb.writeln(request.headers.headerLines());
  sb.writeln();
  sb.writeln(request.bodyAsString);

  sb.writeln("--------------------------------------------------------");
  sb.writeln();
  sb.writeln("Response");
  sb.writeln("${response?.protocolVersion} ${response?.status.code}");
  sb.writeln(response?.headers.headerLines());
  sb.writeln(response?.bodyAsString);
  return sb.toString();
}

RelativeRect menuPosition(BuildContext context) {
  final RenderBox bar = context.findRenderObject() as RenderBox;
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  const Offset offset = Offset.zero;
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      bar.localToGlobal(bar.size.centerRight(offset), ancestor: overlay),
      bar.localToGlobal(bar.size.centerRight(offset), ancestor: overlay),
    ),
    offset & overlay.size,
  );
  return position;
}

Widget contextMenu(BuildContext context, EditableTextState editableTextState) {
  List<ContextMenuButtonItem> list = [
    ContextMenuButtonItem(
      onPressed: () {
        editableTextState.copySelection(SelectionChangedCause.tap);

        FlutterToastr.show(AppLocalizations.of(context)!.copied, context);
        unSelect(editableTextState);
        editableTextState.hideToolbar();
      },
      type: ContextMenuButtonType.copy,
    ),
    ContextMenuButtonItem(
      label: Localizations.localeOf(context) == const Locale.fromSubtags(languageCode: 'zh') ? '复制值' : 'Copy Value',
      onPressed: () {
        unSelect(editableTextState);
        Clipboard.setData(ClipboardData(text: editableTextState.textEditingValue.text)).then((value) {
          FlutterToastr.show(AppLocalizations.of(context)!.copied, context);
          editableTextState.hideToolbar();
        });
      },
      type: ContextMenuButtonType.custom,
    ),
    ContextMenuButtonItem(
      onPressed: () {
        editableTextState.selectAll(SelectionChangedCause.tap);
      },
      type: ContextMenuButtonType.selectAll,
    )
  ];
  if (Platform.isIOS) {
    list.add(ContextMenuButtonItem(
      onPressed: () async {
        editableTextState.shareSelection(SelectionChangedCause.toolbar);
      },
      type: ContextMenuButtonType.share,
    ));
  }

  return AdaptiveTextSelectionToolbar.buttonItems(
    anchors: editableTextState.contextMenuAnchors,
    buttonItems: list,
  );
}

void unSelect(EditableTextState editableTextState) {
  editableTextState.userUpdateTextEditingValue(
    editableTextState.textEditingValue.copyWith(selection: const TextSelection(baseOffset: 0, extentOffset: 0)),
    SelectionChangedCause.tap,
  );
}

///Future
Widget futureWidget<T>(Future<T> future, Widget Function(T data) toWidget, {bool loading = false}) {
  return FutureBuilder<T>(
    future: future,
    builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }
        return toWidget(snapshot.requireData);
      }
      //加载效果
      return loading ? const Center(child: CircularProgressIndicator()) : const SizedBox();
    },
  );
}

Future showContextMenu(BuildContext context, Offset offset, {required List<PopupMenuEntry> items}) {
  return showMenu(
      context: context,
      surfaceTintColor:
          Brightness.dark == Theme.of(context).brightness ? null : Theme.of(context).colorScheme.primaryContainer,
      position: RelativeRect.fromLTRB(
        offset.dx + 10,
        offset.dy - 50,
        offset.dx + 10,
        offset.dy - 50,
      ),
      items: items);
}

Future<T?> showConfirmDialog<T>(BuildContext context, {String? title, String? content, VoidCallback? onConfirm}) {
  title ??= AppLocalizations.of(context)!.confirmTitle;
  content ??= AppLocalizations.of(context)!.confirmContent;
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title!),
          content: Text(content!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (onConfirm != null) onConfirm();
              },
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        );
      });
}
