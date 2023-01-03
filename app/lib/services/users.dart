import 'dart:convert';

import 'package:app/util/options.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'auth.dart';

// GET /user => returns own data
// GET /user/:username => returns desired user if you are in the desired users contacts field
// POST /user => creates your own user
// PUT /user => updates your own user
// DELETE /user => deletes your own user

class User {
  late final String username;
  String? fullname;
  Map<String, String> dynamicProperties = {};
  Set<String>? contacts;

  User({
    required this.username,
    required this.fullname,
    required this.dynamicProperties,
    this.contacts,
  }) {
    contacts = contacts ?? {};
  }

  User.fromJson(Map<String, dynamic> json) {
    username = json["username"];
    fullname = json["fullname"];
    contacts = Set<String>.from(json["contacts"] ?? []);
    for (String option in Options.map.keys) {
      if (json[option] is String) {
        dynamicProperties[option] = json[option];
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "fullname": fullname,
      "contacts": [...?contacts],
      ...Options.map.map((key, value) => MapEntry(
          key, null)), // set all properties to null to remove them if not set
      ...dynamicProperties
    };
  }
}

// TODO: persist stuff to shared prefs to safe networking actions

class UsersService extends ChangeNotifier {
  final String baseUrl;
  // TODO: decouple by just taking the authToken in the constructor
  final AuthService authService;
  User? _currentUser;
  String? _token;

  UsersService({
    this.baseUrl = "https://users.connact.fbr.ai",
    required this.authService,
  });

  // TODO: clear current user on logout
  Future<User> get currentUser async {
    if (_currentUser != null) {
      return _currentUser!;
    }

    http.Response response = await _sendRequest('GET', "$baseUrl/user");
    // TODO: need other status code here
    if (response.statusCode == 400) {
      // catch user not found
      throw NotFoundException();
    }

    Map<String, dynamic> userJson = jsonDecode(response.body);
    return User.fromJson(userJson);
  }

  Future<User> get(String username) async {
    http.Response response =
        await _sendRequest('GET', "$baseUrl/user/$username");

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    Map<String, dynamic> userJson = jsonDecode(response.body);

    return User.fromJson(userJson);
  }

  Future<void> create(User user) async {
    http.Response response =
        await _sendRequest('POST', "$baseUrl/user", body: user.toJson());

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    Map<String, dynamic> userJson = jsonDecode(response.body);

    _currentUser = User.fromJson(userJson);

    notifyListeners();
  }

  Future<void> update(User user) async {
    http.Response response =
        await _sendRequest('PUT', "$baseUrl/user", body: user.toJson());

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    Map<String, dynamic> userJson = jsonDecode(response.body);

    _currentUser = User.fromJson(userJson);

    notifyListeners();
  }

  Future<http.Response> _sendRequest(String method, String url,
      {Object? body}) async {
    http.Request req = http.Request(method, Uri.parse(url));
    if (body != null) {
      req.body = jsonEncode(body);
    }

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

class NotFoundException implements Exception {
  @override
  String toString() {
    return "requested entity not found";
  }
}
