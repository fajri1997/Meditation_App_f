import 'package:meditation_app/models/token.dart';
import 'package:meditation_app/services/authService.dart';

class AuthRepo {
  // Asynchronous method to handle user signup
  Future<Token?> signupRepo(user) async {
    try {
      // Call the signup method from the AuthService
      final String response = await AuthService().signup(user: user);

      // Parse the response and create a Token instance
      final tokenModel = Token.fromJson({'token': response});

      // Return the Token instance
      return tokenModel;
    } catch (e) {
      // Handle errors, e.g., display an error message or log the error
      print('Error during signupRepo: $e');

      // Rethrow the error if needed
      throw e;
    }
  }
}
