import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.instance.loadToken();
  runApp(const ShifterApp());
}

class ShifterApp extends StatelessWidget {
  const ShifterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'priyashifter',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: ApiService.instance.isLoggedIn ? const HomeScreen() : const SignInScreen(),
    );
  }
}
