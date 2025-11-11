import 'package:chatapp/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';

import '../bloc/chat_messages/chat_messages_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String role = 'vendor';

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.surfaceContainerHighest,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      color: color.primary, size: 72),
                  const SizedBox(height: 12),
                  Text('Chat Portal',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => SValidator.validateEmail(value),
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Iconsax.direct_right)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    validator: (value) => SValidator.validatePassword(value),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Iconsax.password_check),
                        suffixIcon: IconButton(
                          tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.8),
                          ),
                        )),
                    obscureText: !_isPasswordVisible,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Vendor'),
                        selected: role == 'vendor',
                        onSelected: (_) => setState(() => role = 'vendor'),
                      ),
                      ChoiceChip(
                        label: const Text('Customer'),
                        selected: role == 'customer',
                        onSelected: (_) => setState(() => role = 'customer'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) async {
                      if (state is AuthSuccess) {
                        final prefs = await SharedPreferences.getInstance();
                        final response = state.response;

                        final token = response['data']?['token'];
                        final user = response['data']?['user'];
                        final userId = user?['_id'];

                        if (token != null) {
                          await prefs.setString('auth_token', token);
                        }
                        if (userId != null) {
                          await prefs.setString('user_id', userId);
                        }

                        final socketManager =
                            context.read<ChatMessagesBloc>().socketManager;
                        if (!socketManager.isConnected) {
                          socketManager.connect(token: token);
                        }

                        Navigator.pushReplacementNamed(context, '/chats');
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
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.login_rounded,
                              color: color.onPrimary),
                          label: const Text('Login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color.primary,
                            foregroundColor: color.onPrimary,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              LoginRequested(
                                _email.text.trim(),
                                _password.text.trim(),
                                role,
                              ),
                            );
                          },
                        ),
                      );
                    },
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



