import 'package:qr_generator/model/response.dart';
import 'package:qr_generator/model/tinyurl.dart';
import 'package:qr_generator/service/api.dart';

class TinyUrlRepo{
  //TODO: Fetch from Firebase Remote Config
  Map<String, String> headers = {
    "Authorization": "Bearer xxx",
  };

  late ApiService tinyUrlService;

  TinyUrlRepo(){
    tinyUrlService = ApiService("https://api.tinyurl.com", headers);
  }

  Future<Response<List<TinyUrl>>> getUrls() async{
    const endPoint = '/urls';

    final response = await tinyUrlService.get(endPoint);

    if (response.isSuccess()) {
      List<TinyUrl> result = [];
      response.data!.forEach((map) {
        result.add(TinyUrl.fromJson(map));
      });

      return Response.success(result);
    } else {
      return Response.fail(response.code, response.message);
    }
  }

  Future<Response<TinyUrl>> shortenUrl({required String longUrl, required String alias}) async{
    const endPoint = '/create';

    Map<String, dynamic> params = {
      "url": longUrl,
      "domain": "tinyurl.com",
      "alias": alias
    };

    final response = await tinyUrlService.post(endPoint, params: params);

    if (response.isSuccess()) {
      return Response.success(TinyUrl.fromJson(response.data));
    } else {
      return Response.fail(response.code, response.message, errors: response.errors);
    }
  }

}