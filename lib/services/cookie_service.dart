import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class ApiService {
  final String baseUrl = 'https://bakery.permavite.com'; // Your API URL
  final Dio dio = Dio(); // Create an instance of Dio
  final CookieJar cookieJar = PersistCookieJar(); // Use Persistent Cookie Jar for saving cookies

  ApiService() {
    // Set up Dio with the cookie manager
    dio.interceptors.add(CookieManager(cookieJar));
    dio.options.baseUrl = baseUrl;
  }

  // Function to log in and receive session cookie
  Future<void> login(String username, String password) async {
    final response = await dio.post(
      '/login',
      options: Options(contentType: Headers.jsonContentType),
      data: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      print('Login successful, cookies managed automatically.');
    } else {
      throw Exception('Failed to log in: ${response.data}');
    }
  }

  // Function to make an authenticated request
  Future<void> fetchData() async {
    final response = await dio.get('/data'); // Automatically sends cookies with the request

    if (response.statusCode == 200) {
      // Handle the response
      print('Data: ${response.data}');
    } else {
      throw Exception('Failed to fetch data: ${response.data}');
    }
  }

  // Function to log out and clear the session
  Future<void> logout() async {
    // Clear cookies from the cookie jar
    await cookieJar.deleteAll();
    print('Logged out and cookies cleared.');
  }
}
