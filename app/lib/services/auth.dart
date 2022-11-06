import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// POST /signup => registers new user
// POST /login => logs in user

class User {
  String username;
  String displayName;

  User({required this.username, required this.displayName});
}

const tokenKey = "connactJwtToken";

class AuthService extends ChangeNotifier {
  final String baseUrl;
  final _storage = const FlutterSecureStorage();

  bool? _loggedIn;
  Future<bool> get loggedIn async {
    if (_loggedIn == null) {
      String? jwtToken = await _storage.read(key: tokenKey);
      // TODO: check if jwt is expired?
      _loggedIn = jwtToken != null;
    }

    return _loggedIn!;
  }

  AuthService({this.baseUrl = "https://auth.connact.fbr.ai"});

  Future<void> login(String username, String password) async {
    http.Response response = await http.post(Uri.parse("$baseUrl/login"),
        body: {"username": username, "password": password});

    _storage.write(key: tokenKey, value: extractToken(response.body));

    _loggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: tokenKey);
    _loggedIn = false;
    notifyListeners();
  }

  Future<void> signUp(String username, String password, String email) async {
    http.Response response = await http.post(Uri.parse("$baseUrl/signup"),
        body: {"username": username, "password": password, "email": email});

    _storage.write(key: tokenKey, value: extractToken(response.body));

    _loggedIn = true;
    notifyListeners();
  }
}

String extractToken(String bodyJson) {
  Map<String, dynamic> body = jsonDecode(bodyJson);
  String? error = body["error"];
  if (error != null) {
    // TODO: use custom exception to improve error handling
    throw Exception(error);
  }

  return body["token"];
}
