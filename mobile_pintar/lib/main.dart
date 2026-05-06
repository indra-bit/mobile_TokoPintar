import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MobilePintarApp(),
    ),
  );
}

class MobilePintarApp extends StatelessWidget {
  const MobilePintarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Mart',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90E2)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitChecked = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    Future.microtask(() async {
      await auth.checkInitialAuth();
      if (mounted) {
        setState(() {
          _isInitChecked = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isAuthenticated) {
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
