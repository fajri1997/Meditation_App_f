import 'package:flutter/material.dart';
import 'package:meditation_app/models/user.dart';
import 'package:meditation_app/services/authService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService = AuthService();
  String token = "";
  String _username = "";

  // Setter for username with notification to listeners
  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  // Getter for username
  String getUserUsername() {
    return _username;
  }

  // SignUp method
  Future<String> signup({required User user}) async {
    token = await authService.signup(user: user);
    saveTokenInStorage(token);
    // Notify listeners about changes in the authentication state
    notifyListeners();
    return token;
  }

  // SignIn method
  Future<String> signin({required User user}) async {
    token = await authService.signin(user: user);
    _username = user.username;
    saveTokenInStorage(token);
    // Notify listeners about changes in the authentication state
    notifyListeners();
    return token;
  }

  // Save token to local storage
  Future<void> saveTokenInStorage(String token) async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setString('token', token);
  }

  // Read token from local storage
  Future<String?> readTokenInStorage() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    return shared.getString('token');
  }

  // Logout method
  Future<void> logout() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    // Clear the token from local storage
    await shared.remove('token');
    // Clear token and username in memory
    token = "";
    _username = "";
    // Notify listeners about changes in the authentication state (user logout)
    notifyListeners();
  }

  // Update profile method
  Future<bool> updateProfile(String username, String password) async {
    String? storedToken = await readTokenInStorage();
    if (storedToken == null || storedToken.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    try {
      bool success = await authService.updateProfile(
        username: username,
        password: password,
        token: storedToken,
      );

      if (success) {
        _username = username;
        // Notify listeners about changes in the user profile
        notifyListeners();
        return true;
      } else {
        // You can throw a more specific exception if needed
        throw Exception(
            'Failed to update the profile. The server response was unsuccessful.');
      }
    } on DioError catch (dioError) {
      // Handle DioError specifically if you want to extract response data
      throw Exception(
          'Failed to update profile: ${dioError.response?.data['message'] ?? dioError.message}');
    } catch (e) {
      // Any other exception that might occur
      rethrow; // This will pass the exception back to the caller
    }
  }

  // Getter for authentication token
  String? getAuthToken() {
    return token.isNotEmpty ? token : null;
  }
}
