import 'package:network_proxy/network/http/http.dart';

/// @author wanghongen
/// 2023/8/4
class SearchModel {
  String? keyword;

  //搜索范围
  Set<Option> searchOptions = {Option.url};

  //请求方法
  HttpMethod? requestMethod;

  //请求类型
  ContentType? requestContentType;

  //响应类型
  ContentType? responseContentType;

  //状态码
  int? statusCode;

  SearchModel([this.keyword]);

  bool get isNotEmpty {
    return keyword?.trim().isNotEmpty == true ||
        requestMethod != null ||
        requestContentType != null ||
        responseContentType != null ||
        statusCode != null;
  }

  bool get isEmpty {
    return !isNotEmpty;
  }

  ///是否匹配
  bool filter(HttpRequest request, HttpResponse? response) {
    if (isEmpty) {
      return true;
    }

    if (requestMethod != null && requestMethod != request.method) {
      return false;
    }
    if (requestContentType != null && request.contentType != requestContentType) {
      return false;
    }

    if (responseContentType != null && response?.contentType != responseContentType) {
      return false;
    }
    if (statusCode != null && response?.status.code != statusCode) {
      return false;
    }

    if (keyword == null || keyword?.isEmpty == true || searchOptions.isEmpty) {
      return true;
    }

    for (var option in searchOptions) {
      if (keywordFilter(keyword!, option, request, response)) {
        return true;
      }
    }

    return false;
  }

  ///关键字过滤
  bool keywordFilter(String keyword, Option option, HttpRequest request, HttpResponse? response) {
    if (option == Option.url && request.requestUrl.toLowerCase().contains(keyword.toLowerCase())) {
      return true;
    }

    if (option == Option.requestBody && request.bodyAsString.contains(keyword) == true) {
      return true;
    }
    if (option == Option.responseBody && response?.bodyAsString.contains(keyword) == true) {
      return true;
    }
    if (option == Option.method && request.method.name.toLowerCase() == keyword.toLowerCase()) {
      return true;
    }
    if (option == Option.responseContentType && response?.headers.contentType.contains(keyword) == true) {
      return true;
    }

    if (option == Option.requestHeader || option == Option.responseHeader) {
      var entries = option == Option.requestHeader ? request.headers.entries : response?.headers.entries ?? [];

      for (var entry in entries) {
        if (entry.key.toLowerCase() == keyword.toLowerCase() ||
            entry.value.any((element) => element.contains(keyword))) {
          return true;
        }
      }
    }
    return false;
  }

  ///复制对象
  SearchModel clone() {
    var searchModel = SearchModel(keyword);
    searchModel.searchOptions = searchOptions;
    searchModel.requestMethod = requestMethod;
    searchModel.requestContentType = requestContentType;
    searchModel.responseContentType = responseContentType;
    searchModel.statusCode = statusCode;
    return searchModel;
  }

  @override
  String toString() {
    return 'SearchModel{keyword: $keyword, searchOptions: $searchOptions, responseContentType: $responseContentType, requestMethod: $requestMethod, requestContentType: $requestContentType, statusCode: $statusCode}';
  }
}

enum Option {
  url,
  method,
  responseContentType,
  requestHeader,
  requestBody,
  responseHeader,
  responseBody,
}
