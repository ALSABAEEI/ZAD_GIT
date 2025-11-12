import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import 'restaurant_home_page.dart';
import 'charity_home_page.dart';
import 'registration_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade50,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.all(24),
                duration: const Duration(seconds: 3),
              ),
            );
          }
          if (state is LoginSuccess) {
            if (state.role == 'Restaurant') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const RestaurantHomePage()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CharityHomePage()),
              );
            }
          }
        },
        builder: (context, state) {
          final bloc = context.read<LoginBloc>();
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFf8fafc),
                    Color(0xFFe0e7ff),
                    Color(0xFFfef9c3),
                  ],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.10),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.login,
                                color: Colors.deepPurple,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Login to your account',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back! Please enter your credentials.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter Email',
                            labelStyle: const TextStyle(fontSize: 13),
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              size: 18,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.deepPurple.shade50,
                          ),
                          onChanged: (v) => bloc.add(LoginEmailChanged(v)),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          obscureText: true,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Password',
                            labelStyle: const TextStyle(fontSize: 13),
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 18,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.deepPurple.shade50,
                            suffixIcon: const Icon(Icons.visibility_off),
                          ),
                          onChanged: (v) => bloc.add(LoginPasswordChanged(v)),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>((
                                    Set<MaterialState> states,
                                  ) {
                                    if (states.contains(
                                      MaterialState.disabled,
                                    )) {
                                      return Colors.deepPurple.shade200;
                                    }
                                    return Colors.deepPurpleAccent;
                                  }),
                              foregroundColor:
                                  MaterialStateProperty.resolveWith<Color>((
                                    Set<MaterialState> states,
                                  ) {
                                    return Colors.white;
                                  }),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 16),
                              ),
                              elevation: MaterialStateProperty.all(4),
                            ),
                            onPressed: state is LoginLoading
                                ? null
                                : () => bloc.add(LoginSubmitted()),
                            child: state is LoginLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegistrationPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.deepPurple.shade700,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
