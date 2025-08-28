import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Change this to your PC IP if using real device
const String serverIP = "127.0.0.1"; 
const int port = 3000;

void main() async {
  final userId = await doLogin();
  if (userId != null) await expenseMenu(userId);
  print("Program ended.");
}

