import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  final Dio dio;
  DioClient._(this.dio);

  static Future<DioClient> create({String baseUrl = 'http://45.129.87.38:6065'}) async {
    final options = BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 15));
    final dio = Dio(options);

    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }, onError: (err, handler) {
      handler.next(err);
    }));

    return DioClient._(dio);
  }
}