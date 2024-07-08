import 'dart:async';
import 'dart:convert';

import 'package:qr_generator/model/response.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

const Duration _defaultTimeout = Duration(seconds: 20);

class ApiService{
  String domain;
  Map<String, String> headers = {};
  ApiService(this.domain, this.headers){
    headers.addAll({
    "Content-Type": "application/json",
      "Accept": "application/json"
    });
  }

  Future<Response<dynamic>> get(
      String endpoint, {
        Map<String, dynamic>? queryParams,
        Duration timeout = _defaultTimeout,
      }) async {
    String queryString = Uri(queryParameters: queryParams).query;
    var url = Uri.parse(
        domain + endpoint + '?' + queryString);
    print("GET API: $url");
    var response;
    try {
      response = await http.get(url, headers: headers).timeout(timeout);
      // print("Response: ${response.body}");
    } catch (e) {
      if (e is TimeoutException) return Response.fail(-2, "Timeout");
      return Response.fail(-1, "Network Error");
    }

    return _handleResponse(response);
  }

  Future<Response<dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? params,
        Map<String, String>? files,
        Duration timeout = _defaultTimeout,
      }) async {
    var url = Uri.parse(domain + endpoint);
    // print("POST API: $url");
    var response;
    try {
      if (files == null || files.isEmpty) {
        response = await http
            .post(url, headers: headers, body: jsonEncode(params))
            .timeout(timeout);
      } else {
        var request = http.MultipartRequest("POST", url);
        request.headers['authorization'] = headers['Authorization']!;
        params?.forEach((k, v) {
          request.fields[k] = v;
        });
        files.forEach((key, path) async {
          request.files.add(await http.MultipartFile.fromPath(
            key,
            path,
            contentType: MediaType('application', 'x-tar'),
          ));
        });

        response = await request.send();
      }
    } catch (e) {
      if (e is TimeoutException) return Response.fail(-2, "Timeout");
      return Response.fail(-1, "Network Error");
    }

    return _handleResponse(response);
  }


  static Future<Response> _handleResponse(response) async {
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      try {
        if (response is http.StreamedResponse) {
          String body = await response.stream.bytesToString();
          Map<String, dynamic> data = json.decode(body);
          return Response.success(data['data'],
              meta: data['meta'], message: data['message']);
        } else if (response.body.isEmpty)
          return Response.success({});
        else {
          Map<String, dynamic> data = json.decode(response.body);
          return Response.success(data['data'],
              meta: data['meta'], message: data['message']);
        }
      } catch (ex) {
        return Response.fail(-1, '$ex');
      }
    }


    var res = json.decode(response.body);

    int code = -1;

    if (res['code'] != null) {
      code = res['code'];
    } else if (res['data'] != null && res['data']['code'] != null) {
      code = res['data']['code'];
    }

    return Response.fail(
      code,
      res['message'] ?? 'Network error',
      errors: res['errors'] != null
          ? List<String>.from(res['errors'])
          : null,
    );
  }

}