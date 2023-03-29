import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final storage = FlutterSecureStorage();
enum Method { get, post }

// apiInstance를 만듭니다
Future<dynamic> apiInstance({
  // parameter로 path, method, success 콜백함수, fail 콜백함수, body를 받습니다
  required String path,
  required Method method,
  required dynamic Function(dynamic) success,
  required Function(String error) fail,
  Map<String, dynamic>? body,
}) async {
  // api URL 주소를 넣습니다
  String URL = 'http://10.0.2.2:8080/api/v1$path';
  // uri 형식으로 변경합니다
  final url = Uri.parse(URL);
  Future<String?> futureString = storage.read(key: "accessToken");
  String? accessToken = await futureString;

  // 기본 headers
  Map<String, String> headers = {
    "Content-Type": "application/json;charset=utf-8",
    "accessToken": "$accessToken",
  };

  // response 값입니다
  late http.Response response;

  // method에 따라 다르게 요청하고 response값을 받습니다
  switch (method) {
    case Method.get:
      response = await http.get(
          url,
          headers: headers
      );
      break;
    case Method.post:
      response = await http.post(
          url,
          headers: headers,
          body: body
      );
      break;
  }

  if (200 <= response.statusCode && response.statusCode < 300) {
    // statuse가 200대이면 성공으로 해서 jsonResponse를 쓰는 콜백함수로 보내줍니다
    dynamic jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
    // Iterable list = jsonResponse;
    // return list.toList(growable: true);
    return success(jsonResponse);
  } else {
    // 200대가 아니면 에러 코드를 보내줍니다
    fail('${response.statusCode} 에러');
  }
}