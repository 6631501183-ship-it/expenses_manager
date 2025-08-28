// for http connection
import 'package:http/http.dart' as http;
// for stdin
import 'dart:io';


void main() async {
  await doLogin();
  print("Good bye");
}
// ================= Login ===================
Future<String?> doLogin() async {
  print("=== Expense Tracker Login ===");
  stdout.write("Username: ");
  final uname = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  final pwd = stdin.readLineSync()?.trim();

  if (uname == null || pwd == null || uname.isEmpty || pwd.isEmpty) {
    print("Username or password cannot be empty.");
    return null;
  }

  final url = Uri.parse("http://localhost:3000/login");
  final res = await http.post(url, body: {"username": uname, "password": pwd});

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    print("Login successful!");
    return data["id"].toString();
  } else {
    final err = jsonDecode(res.body);
    print("Login failed: $err");
    return null;
  }
}



