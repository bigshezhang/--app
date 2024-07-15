/*
 * Copyright 2023 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';
import 'dart:math';

import 'package:network_proxy/network/host_port.dart';
import 'package:network_proxy/network/http/websocket.dart';
import 'package:network_proxy/network/util/logger.dart';
import 'package:network_proxy/network/util/process_info.dart';
import 'package:network_proxy/utils/compress.dart';

import 'http_headers.dart';

///定义HTTP消息的接口，为HttpRequest和HttpResponse提供公共属性。
abstract class HttpMessage {
  ///内容类型
  static final Map<String, ContentType> contentTypes = {
    "javascript": ContentType.js,
    "text/css": ContentType.css,
    "font-woff": ContentType.font,
    "text/html": ContentType.html,
    "text/plain": ContentType.text,
    "application/x-www-form-urlencoded": ContentType.formUrl,
    "form-data": ContentType.formData,
    "image": ContentType.image,
    "application/json": ContentType.json
  };

  String protocolVersion;

  final HttpHeaders headers = HttpHeaders();

  int get contentLength => headers.contentLength;

  //报文大小
  int? packageSize;

  List<int>? body;
  String? remoteAddress;

  String requestId = (DateTime.now().millisecondsSinceEpoch + Random().nextInt(99999)).toRadixString(36);
  int? streamId; // http2 streamId
  HttpMessage(this.protocolVersion);

  //json序列化
  factory HttpMessage.fromJson(Map<String, dynamic> json) {
    if (json["_class"] == "HttpRequest") {
      return HttpRequest.fromJson(json);
    }

    return HttpResponse.fromJson(json);
  }

  Map<String, dynamic> toJson();

  /// 是否是websocket协议
  bool get isWebSocket => headers.get("Upgrade") == 'websocket';

  ContentType get contentType => contentTypes.entries
      .firstWhere((element) => headers.contentType.contains(element.key),
          orElse: () => const MapEntry("unknown", ContentType.http))
      .value;

  String get bodyAsString {
    if (body == null || body?.isEmpty == true) {
      return "";
    }
    try {
      if (headers.contentEncoding == 'br') {
        return utf8.decode(brDecode(body!));
      }
      return utf8.decode(body!);
    } catch (e) {
      return String.fromCharCodes(body!);
    }
  }

  String get cookie => headers.cookie;

  List<WebSocketFrame> messages = [];
}

///HTTP请求。
class HttpRequest extends HttpMessage {
  String uri;
  late HttpMethod method;

  HostAndPort? hostAndPort;
  DateTime requestTime = DateTime.now(); //请求时间
  HttpResponse? response;
  Map<String, dynamic> attributes = {};
  ProcessInfo? processInfo;

  HttpRequest(this.method, this.uri, {String protocolVersion = "HTTP/1.1"}) : super(protocolVersion);

  String? remoteDomain() {
    if (hostAndPort == null) {
      try {
        var uri = Uri.parse(requestUrl);
        return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
      } catch (e) {
        return null;
      }
    }
    return hostAndPort?.domain;
  }

  String get requestUrl => uri.startsWith("/") ? '${remoteDomain()}$uri' : uri;

  /// 请求的uri
  Uri? get requestUri {
    try {
      return Uri.parse(requestUrl);
    } catch (e) {
      return null;
    }
  }

  String? path() {
    try {
      var requestPath = Uri.parse(requestUrl).path;
      return requestPath.isEmpty ? "/" : requestPath;
    } catch (e) {
      return "/";
    }
  }

  Map<String, String> get queries {
    try {
      return Uri.parse(requestUrl).queryParameters;
    } catch (e) {
      return {};
    }
  }

  ///复制请求
  HttpRequest copy({String? uri}) {
    var request = HttpRequest(method, uri ?? this.uri, protocolVersion: protocolVersion);
    request.headers.addAll(headers);
    request.body = body;
    return request;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_class': 'HttpRequest',
      'uri': requestUrl,
      'method': method.name,
      'packageSize': packageSize,
      'headers': headers.toJson(),
      'body': body == null ? null : String.fromCharCodes(body!),
      'requestTime': requestTime.millisecondsSinceEpoch,
    };
  }

  factory HttpRequest.fromJson(Map<String, dynamic> json) {
    var request = HttpRequest(HttpMethod.valueOf(json['method']), json['uri']);
    request.headers.addAll(HttpHeaders.fromJson(json['headers']));
    request.body = json['body']?.toString().codeUnits;
    if (json['requestTime'] != null) {
      request.requestTime = DateTime.fromMillisecondsSinceEpoch(json['requestTime']);
    }
    request.packageSize = json['packageSize'];
    return request;
  }

  @override
  String toString() {
    return 'HttpRequest{version: $protocolVersion, url: $uri, method: ${method.name}, headers: $headers, contentLength: $contentLength, bodyLength: ${body?.length}}';
  }
}

enum ContentType {
  json,
  formUrl,
  formData,
  js,
  html,
  text,
  css,
  font,
  image,
  http;

  static ContentType valueOf(String name) {
    return ContentType.values.firstWhere((element) => element.name == name.toLowerCase(), orElse: () => http);
  }
}

///HTTP响应。
class HttpResponse extends HttpMessage {
  HttpStatus status;
  DateTime responseTime = DateTime.now();
  HttpRequest? request;

  HttpResponse(this.status, {String protocolVersion = "HTTP/1.1"}) : super(protocolVersion);

  String costTime() {
    if (request == null) {
      return '';
    }
    var cost = responseTime.difference(request!.requestTime).inMilliseconds;
    if (cost > 1000) {
      return '${(cost / 1000).toStringAsFixed(2)}s';
    }
    return '${cost}ms';
  }

  //json序列化
  factory HttpResponse.fromJson(Map<String, dynamic> json) {
    var httpResponse = HttpResponse(HttpStatus(json['status']['code'], json['status']['reasonPhrase']),
        protocolVersion: json['protocolVersion'])
      ..headers.addAll(HttpHeaders.fromJson(json['headers']))
      ..body = json['body']?.toString().codeUnits;
    if (json['responseTime'] != null) {
      httpResponse.responseTime = DateTime.fromMillisecondsSinceEpoch(json['responseTime']);
    }
    httpResponse.packageSize = json['packageSize'];
    return httpResponse;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_class': 'HttpResponse',
      'protocolVersion': protocolVersion,
      'packageSize': packageSize,
      'status': {
        'code': status.code,
        'reasonPhrase': status.reasonPhrase,
      },
      'headers': headers.toJson(),
      'body': body == null ? null : String.fromCharCodes(body!),
      'responseTime': responseTime.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'HttpResponse{status: ${status.code}, headers: $headers, contentLength: $contentLength, bodyLength: ${body?.length}}';
  }
}

///HTTP请求方法。
enum HttpMethod {
  get("GET"),
  post("POST"),
  put("PUT"),
  patch("PATCH"),
  delete("DELETE"),
  options("OPTIONS"),
  head("HEAD"),
  trace("TRACE"),
  connect("CONNECT"),
  propfind("PROPFIND"),
  report("REPORT"),
  ;

  final String name;

  const HttpMethod(this.name);

  static HttpMethod valueOf(String name) {
    try {
      return HttpMethod.values.firstWhere((element) => element.name == name.toUpperCase());
    } catch (error) {
      logger.e("HttpMethod error $name :$error");
      rethrow;
    }
  }

  static List<HttpMethod> methods() {
    return values.where((method) => method != HttpMethod.propfind && method != HttpMethod.report).toList();
  }
}

///HTTP响应状态。
class HttpStatus {
  /// 200 OK
  static final HttpStatus ok = newStatus(200, "OK");

  /// 400 Bad Request
  static final HttpStatus badRequest = newStatus(400, "Bad Request");

  /// 401 Unauthorized
  static final HttpStatus unauthorized = newStatus(401, "Unauthorized");

  /// 403 Forbidden
  static final HttpStatus forbidden = newStatus(403, "Forbidden");

  /// 404 Not Found
  static final HttpStatus notFound = newStatus(404, "Not Found");

  /// 500 Internal Server Error
  static final HttpStatus internalServerError = newStatus(500, "Internal Server Error");

  /// 502 Bad Gateway
  static final HttpStatus badGateway = newStatus(502, "Bad Gateway");

  /// 503 Service Unavailable
  static final HttpStatus serviceUnavailable = newStatus(503, "Service Unavailable");

  /// 504 Gateway Timeout
  static final HttpStatus gatewayTimeout = newStatus(504, "Gateway Timeout");

  static HttpStatus newStatus(int statusCode, String reasonPhrase) {
    return HttpStatus(statusCode, reasonPhrase);
  }

  static HttpStatus valueOf(int code) {
    switch (code) {
      case 200:
        return ok;
      case 400:
        return badRequest;
      case 401:
        return unauthorized;
      case 403:
        return forbidden;
      case 404:
        return notFound;
      case 500:
        return internalServerError;
      case 502:
        return badGateway;
      case 503:
        return serviceUnavailable;
      case 504:
        return gatewayTimeout;
    }
    return HttpStatus(code, "");
  }

  final int code;
  String reasonPhrase;

  HttpStatus reason(String reasonPhrase) {
    this.reasonPhrase = reasonPhrase;
    return this;
  }

  HttpStatus(this.code, this.reasonPhrase);

  bool isSuccessful() {
    return code >= 200 && code < 300;
  }

  @override
  String toString() {
    return '$code  $reasonPhrase';
  }
}
