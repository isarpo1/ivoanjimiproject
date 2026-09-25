import 'package:flutter/material.dart';

import 'core/api/api_client.dart';
import 'core/storage/token_storage.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final token = await TokenStorage.getToken();

  bool isLoggedIn = false;

  if (token != null && token.isNotEmpty) {
    try {
      await ApiClient.get('/users/me', token: token);

      isLoggedIn = true;
    } catch (_) {
      await TokenStorage.deleteToken();
      isLoggedIn = false;
    }
  }

  runApp(IvoanjimiApp(isLoggedIn: isLoggedIn));
}

class IvoanjimiApp extends StatelessWidget {
  final bool isLoggedIn;

  const IvoanjimiApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ivoanjimi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
