import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:koala/app/data/models/loan_model.dart';
import 'package:koala/app/data/models/transaction_model.dart';
import 'package:koala/app/data/models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-url.com';
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Future<Map<String, dynamic>> login({
    required String pin,
    required String deviceId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'pin': pin, 'device_id': deviceId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  static Future<UserModel> getUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user: ${response.body}');
    }
  }

  static Future<UserModel> updateUser(UserModel user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user'),
      headers: _headers,
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  static Future<List<TransactionModel>> getTransactions({
    String? from,
    String? to,
    String? category,
    int page = 1,
    int perPage = 50,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (category != null) 'category': category,
    };

    final response = await http.get(
      Uri.parse('$baseUrl/transactions').replace(queryParameters: queryParams),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['items'] as List)
          .map((item) => TransactionModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to get transactions: ${response.body}');
    }
  }

  static Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: _headers,
      body: jsonEncode(transaction.toJson()),
    );

    if (response.statusCode == 201) {
      return TransactionModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create transaction: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getAiInsight({
    required String userQuery,
    String persona = 'insight',
    List<Map<String, dynamic>>? history,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/insight'),
      headers: _headers,
      body: jsonEncode({
        'userQuery': userQuery,
        'persona': persona,
        'history': history ?? [],
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get AI insight: ${response.body}');
    }
  }

  static Future<void> syncPendingData() async {
    // Implementation for syncing offline data to server
    final response = await http.get(
      Uri.parse('$baseUrl/sync/pending'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sync: ${response.body}');
    }
  }
}
