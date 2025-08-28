import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

void main() async {
  final userId = await doLogin();
  if (userId != null) {
    await expenseMenu(userId);
  }
  print("Program ended.");
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

  final url = Uri.parse("⁦http://localhost:3000/login⁩");
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

// ================= Menu ===================
Future<void> expenseMenu(String userId) async {
  while (true) {
    print("\n===== Expense Menu =====");
    print("1) Show all expenses");
    print("2) Show today's expenses");
    print("3) Search expenses");
    print("4) Add expense");
    print("5) Delete expense");
    print("0) Exit");
    stdout.write("Select option: ");
    final choice = stdin.readLineSync();

    switch (choice) {
      case "1":
        await fetchAll(userId);
        break;
      case "2":
        await fetchToday(userId);
        break;
      case "3":
        await findExpense(userId);
        break;
      case "4":
        await createExpense(userId);
        break;
      case "5":
        await removeExpense(userId);
        break;
      case "0":
        return;
      default:
        print("Invalid choice. Try again.");
    }
  }
}

// ================== Features ==================

Future<void> fetchAll(String userId) async {
  final url = Uri.parse("⁦http://localhost:3000/expenses?userId=$userId⁩");
  final res = await http.get(url);

  if (res.statusCode == 200) {
    final list = jsonDecode(res.body) as List;
    int total = 0;
    print("\n--- All Expenses ---");
    for (final exp in list) {
      print("ID: ${exp['id']} | Item: ${exp['item']} | Paid: ${exp['paid']} | Date: ${exp['date']}");
      total += exp["paid"] as int;
    }
    print("Total = $total");
  } else {
    print("Error: ${res.statusCode}");
  }
}

Future<void> fetchToday(String userId) async {
  final now = DateTime.now();
  final today =
      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

  final url =
      Uri.parse("⁦http://localhost:3000/expenses?userId=$userId&date=$today⁩");
  final res = await http.get(url);

  if (res.statusCode == 200) {
    final list = jsonDecode(res.body) as List;
    int sum = 0;
    print("\n--- Today's Expenses ---");
    for (final exp in list) {
      print("ID: ${exp['id']} | Item: ${exp['item']} | Paid: ${exp['paid']} | Date: ${exp['date']}");
      sum += exp["paid"] as int;
    }
    print("Today's total = $sum");
  } else {
    print("Error: ${res.statusCode}");
  }
}

Future<void> findExpense(String userId) async {
  stdout.write("Enter keyword: ");
  final key = stdin.readLineSync()?.trim();

  if (key == null || key.isEmpty) {
    print("Keyword is empty.");
    return;
  }

  final url =
      Uri.parse("⁦http://localhost:3000/expenses?userId=$userId&keyword=$key⁩");
  final res = await http.get(url);

  if (res.statusCode == 200) {
    final result = jsonDecode(res.body) as List;
    if (result.isEmpty) {
      print("No expenses found for '$key'.");
    } else {
      print("\n--- Search Results ---");
      for (final exp in result) {
        print("ID: ${exp['id']} | Item: ${exp['item']} | Paid: ${exp['paid']} | Date: ${exp['date']}");
      }
    }
  } else {
    print("Error: ${res.statusCode}");
  }
}

Future<void> createExpense(String userId) async {
  stdout.write("Item: ");
  final item = stdin.readLineSync()?.trim();
  stdout.write("Amount: ");
  final amtStr = stdin.readLineSync()?.trim();

  if (item == null || amtStr == null || item.isEmpty) {
    print("Invalid input.");
    return;
  }

  try {
    final amount = int.parse(amtStr);
    final body = {"userId": userId, "item": item, "paid": amount};
    final res = await http.post(
      Uri.parse("⁦http://localhost:3000/expenses⁩"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode == 201) {
      print("Expense added.");
    } else {
      print("Error: ${res.statusCode}");
    }
  } catch (e) {
    print("Amount must be a number.");
  }
}

Future<void> removeExpense(String userId) async {
  stdout.write("Enter expense ID: ");
  final idStr = stdin.readLineSync();

  if (idStr == null) {
    print("Missing ID.");
    return;
  }

  try {
    final id = int.parse(idStr);
    final url = Uri.parse("⁦http://localhost:3000/expenses/$id?userId=$userId⁩");
    final res = await http.delete(url);

    if (res.statusCode == 200) {
      print("Expense deleted.");
    } else if (res.statusCode == 404) {
      print("Expense not found.");
    } else {
      print("Error: ${res.statusCode}");
    }
  } catch (e) {
    print("Invalid ID.");
  }
}
