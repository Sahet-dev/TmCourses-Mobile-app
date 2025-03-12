import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = "https://course-server.sahet-dev.com/api/";
    _dio.options.connectTimeout = const Duration(seconds: 610);
    _dio.options.receiveTimeout = const Duration(seconds: 610);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _secureStorage.read(key: 'token');
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle Unauthorized (401) Errors
        if (e.response?.statusCode == 401) {
          print("Unauthorized! Redirecting to login.");
          // Optionally, logout user and navigate to login page
        }
        return handler.next(e);
      },
    ));
  }

  Future<void> sendVerificationCode() async {
    try {
      String? token = await _secureStorage.read(key: 'token');

      Response response = await _dio.post(
        '/send-verification-code',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print(response.data['message']);
    } catch (e) {
      print("Error sending verification code: $e");
    }
  }

  Future<bool> verifyCode(String code) async {
    try {
      String? token = await _secureStorage.read(key: 'token');

      Response response = await _dio.post(
        '/verify-code',
        data: {'code': code},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print(response.data['message']);
      return true;
    } catch (e) {
      print("Error verifying code: $e");
      return false;
    }
  }


  Future<Response> get(String endpoint) async {
    return await _dio.get(endpoint);
  }

  Future<Response> post(String endpoint, dynamic data) async {
    return await _dio.post(endpoint, data: data);
  }

  Future<Response> delete(String endpoint) async {
    return await _dio.delete(endpoint);
  }
}
