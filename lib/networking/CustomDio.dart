import 'package:dio/dio.dart';
import 'package:localgptflutter/data/settings.dart';



String baseURL = SettingsData.apiUrl;
String socketsURL = SettingsData.apiSocketsUrl;



CustomDio() {
  BaseOptions options = BaseOptions(baseUrl: baseURL);

  Dio dio = Dio(options);





  return dio;
}
