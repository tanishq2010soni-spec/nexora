import 'package:flutter/material.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';

class LoginForm extends StatefulWidget {
  final bool isLoading;
  final void Function(String email, String password) onSubmit;

  const LoginForm({super.key, required this.isLoading, required this.onSubmit});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          label: 'Email',
          hint: 'you@company.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Password',
          hint: 'Enter your password',
          controller: _passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Sign In',
            isLoading: widget.isLoading,
            onPressed: () {
              widget.onSubmit(_emailController.text, _passwordController.text);
            },
          ),
        ),
      ],
    );
  }
}
