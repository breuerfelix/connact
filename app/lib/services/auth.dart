import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// POST /signup => registers new user
// POST /login => logs in user

class AuthService {
  String baseUrl;

  AuthService({this.baseUrl = "https://auth.connact.fbr.ai/"});

  Future<void> login(String username, String password) async {
    http.post(Uri.parse("$baseUrl/login"), body: {username, password});

    // TODO:
    // - push user to stream/ change notifier/ whatever
    // - after login fetch user
    // - after login save JWT in secure storage
  }

  Future<void> logout() async {
    // TODO:
    // - remove JWT from secure storage
    // - push null to user stream
  }

  Future<void> singUp() async {
    // TODO: implement
  }
}
