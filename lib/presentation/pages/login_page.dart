import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController(text: 'swaroop.vass@gmail.com');
  final _password = TextEditingController(text: '@Tyrion99');
  String role = 'vendor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Role:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: role,
                  items: const [
                    DropdownMenuItem(value: 'vendor', child: Text('Vendor')),
                    DropdownMenuItem(value: 'customer', child: Text('Customer')),
                  ],
                  onChanged: (v) => setState(() => role = v ?? 'vendor'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) async {
                if (state is AuthSuccess) {
                  final prefs = await SharedPreferences.getInstance();
                  final response = state.response;

                  try {
                    final token = response['data']?['token'];
                    final user = response['data']?['user'];
                    final id = user?['_id'] ?? user?['id'];

                    if (token != null) {
                      await prefs.setString('auth_token', token.toString());
                    }
                    if (id != null) {
                      await prefs.setString('user_id', id.toString());
                      print('✅ Stored user_id: $id');
                    } else {
                      print('⚠️ Could not find user_id in response: $response');
                    }

                    await prefs.setString('user_role', role);

                    Navigator.pushReplacementNamed(context, '/chats');
                  } catch (e) {
                    print('⚠️ Error saving user data: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login data format changed, please retry.')),
                    );
                  }
                } else if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: ${state.error}')),
                  );
                }
              },
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const CircularProgressIndicator();
                }
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        LoginRequested(
                          _email.text.trim(),
                          _password.text.trim(),
                          role,
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text('Login'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
