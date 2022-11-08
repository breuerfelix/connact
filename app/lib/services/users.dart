import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'auth.dart';

// GET /user => returns own data
// GET /user/:username => returns desired user if you are in the desired users contacts field
// POST /user => creates your own user
// PUT /user => updates your own user
// DELETE /user => deletes your own user

class User {
  String username;
  String email;

  User({required this.username, required this.email});

  User.fromJson(Map<String, dynamic> json)
      : username = json["username"],
        email = json["email"];
}

class UsersService {
  final String baseUrl;
  // TODO: decouple by just taking the authToken in the constructor
  final AuthService authService;
  String? _token;

  UsersService({
    this.baseUrl = "https://users.connact.fbr.ai",
    required this.authService,
  });

  Future<User> get currentUser async {
    http.Response response = await _sendRequest('GET', "$baseUrl/user");
    Map<String, dynamic> userJson = jsonDecode(response.body);
    return User.fromJson(userJson);
  }

  Future<http.Response> _sendRequest(String method, String url) async {
    http.Request req = http.Request(method, Uri.parse(url));

    if (_token == null) {
      _token = await authService.token;
      if (_token == null) {
        throw Exception("not logged in yet");
      }
    }

    req.headers["Authorization"] = "Bearer $_token";
    return http.Response.fromStream(await req.send());
  }
}
