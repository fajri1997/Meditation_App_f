import 'package:dio/dio.dart';
import 'package:meditation_app/models/token.dart';
import 'package:meditation_app/models/user.dart';
import 'package:meditation_app/providrors/AuthProvider.dart'; // Assuming this import is necessary

import 'client.dart'; // Assuming this import is necessary for ApiClient

class AuthService {
  get context => null;

  Future<String> signup({required User user}) async {
    try {
      if (user.username.isNotEmpty && user.password.isNotEmpty) {
        final Response response =
            await ApiClient.dio.post("/signup", data: user.toJson());
        Token tokenModel = Token.fromJson(response.data);
        return tokenModel.token.toString();
      }
      return "";
    } catch (e) {
      // Handle DioError or other specific errors
      throw e.toString();
    }
  }

  Future<String> signin({required User user}) async {
    try {
      final Response response =
          await ApiClient.dio.post("/signin", data: user.toJson());
      Token tokenModel = Token.fromJson(response.data);
      return tokenModel.token.toString();
    } catch (e) {
      // Handle DioError or other specific errors
      throw e.toString();
    }
  }

  Future<bool> updateProfile({
    required String username,
    required String password,
    required String token,
  }) async {
    try {
      final Response response = await ApiClient.dio.put(
        "/update",
        data: {
          'username': username,
          'password': password,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode ==
          200; // Return true if the update was successful
    } catch (e) {
      // Handle DioError or other specific errors
      throw e.toString();
    }
  }

  // Additional method for login
  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      // Make an API request to authenticate the user
      final Response response = await ApiClient.dio.post(
        "/login",
        data: {
          'username': username,
          'password': password,
        },
      );

      // Parse the response and extract the authentication token
      Token tokenModel = Token.fromJson(response.data);
      String authToken = tokenModel.token.toString();

      // Set the authentication token in AuthProvider
      context.read<AuthProvider>().setAuthToken(authToken);

      return authToken;
    } catch (e) {
      // Handle DioError or other specific errors
      throw e.toString();
    }
  }
}
