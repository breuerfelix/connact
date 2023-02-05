import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// POST /signup => registers new user
// POST /login => logs in user

const tokenKey = "connactJwtToken";

class AuthService extends ChangeNotifier {
  final String baseUrl;
  final _storage = const FlutterSecureStorage();

  Future<bool> get loggedIn async {
    return await token != null;
  }

  String? _token;
  Future<String?> get token async {
    if (_token != null) {
      return _token;
    }

    return await _storage.read(key: tokenKey);
  }

  AuthService({this.baseUrl = "https://auth.connact.tecios.de"});

  Future<void> login(String username, String password) async {
    http.Response response = await http.post(Uri.parse("$baseUrl/login"),
        body: {"username": username, "password": password});

    _token = extractToken(response.body);
    _storage.write(key: tokenKey, value: _token);

    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: tokenKey);
    _token = null;

    notifyListeners();
  }

  Future<void> signUp(String username, String password, String email) async {
    http.Response response = await http.post(Uri.parse("$baseUrl/signup"),
        body: {"username": username, "password": password, "email": email});

    _token = extractToken(response.body);
    _storage.write(key: tokenKey, value: _token);

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
