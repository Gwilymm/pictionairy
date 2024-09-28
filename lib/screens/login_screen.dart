// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import '../controllers/login_controller.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final LoginController _loginController = LoginController();
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    bool isLoggedIn = await _loginController.login(_formKey);
    if (!mounted) return;

    if (isLoggedIn) {
      // Navigate to HomeScreen on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Handle failed login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please check your credentials.')),
      );
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Piction.AI.ry',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    Icons.lock_outline,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome Back!',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Login to your account',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 40),

                  // Username input
                  TextFormField(
                    controller: _loginController.usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      if (value.length < 3) {
                        return 'Username must be at least 3 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password input
                  TextFormField(
                    controller: _loginController.passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle "Forgot Password"
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  ElevatedButton(
                    onPressed: _login,
                    style: AppTheme.elevatedButtonStyle,
                    child: const Text(
                      'Login',
                      style: AppTheme.buttonTextStyle,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Up Button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    style: AppTheme.outlinedButtonStyle,
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
