import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_page.dart';
import '../bloc/registration_bloc.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFf8fafc), Color(0xFFe0e7ff), Color(0xFFfef9c3)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
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
              child: BlocConsumer<RegistrationBloc, RegistrationState>(
                listener: (context, state) {
                  if (state is RegistrationError) {
                    print('SnackBar error: ${state.message}'); // Debug print
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.message,
                                style: TextStyle(
                                  color: Colors.red.shade900,
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
                  if (state is RegistrationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Registration successful!',
                                style: TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFFD0F8CE), // Light green
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.all(24),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Future.delayed(const Duration(milliseconds: 1200), () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    });
                  }
                },
                builder: (context, state) {
                  final bloc = context.read<RegistrationBloc>();
                  return Column(
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
                              Icons.person_add_alt_1,
                              color: Colors.deepPurple,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Create Account',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create an account to start..',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.deepPurple.shade50,
                        ),
                        onChanged: (v) => bloc.add(EmailChanged(v)),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.deepPurple.shade50,
                          suffixIcon: const Icon(Icons.visibility_off),
                        ),
                        onChanged: (v) => bloc.add(PasswordChanged(v)),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Role',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: bloc.role == 'Organization'
                                      ? Colors.deepPurple
                                      : Colors.white,
                                  foregroundColor: bloc.role == 'Organization'
                                      ? Colors.white
                                      : Colors.deepPurple,
                                  elevation: bloc.role == 'Organization'
                                      ? 4
                                      : 0,
                                  side: BorderSide(
                                    color: Colors.deepPurple.shade200,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () =>
                                    bloc.add(RoleChanged('Organization')),
                                icon: const Icon(Icons.volunteer_activism),
                                label: const Text('Organization'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: bloc.role == 'Restaurant'
                                      ? Colors.deepPurple
                                      : Colors.white,
                                  foregroundColor: bloc.role == 'Restaurant'
                                      ? Colors.white
                                      : Colors.deepPurple,
                                  elevation: bloc.role == 'Restaurant' ? 4 : 0,
                                  side: BorderSide(
                                    color: Colors.deepPurple.shade200,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () =>
                                    bloc.add(RoleChanged('Restaurant')),
                                icon: const Icon(Icons.restaurant_menu),
                                label: const Text('Restaurant'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText:
                                    'Commercial Registration National Number',
                                hintText: 'Enter CRN Number',
                                prefixIcon: const Icon(
                                  Icons.confirmation_number_outlined,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: Colors.deepPurple.shade50,
                              ),
                              onChanged: (v) => bloc.add(CrnChanged(v)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              elevation: 3,
                            ),
                            onPressed: state is RegistrationLoading
                                ? null
                                : () => bloc.add(CheckEligibility()),
                            child: state is RegistrationLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Check',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: state is RegistrationEligibilityChecked
                            ? Padding(
                                key: ValueKey(state.eligible),
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: state.eligible
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: state.eligible
                                          ? Colors.green
                                          : Colors.red,
                                      width: 1.2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        state.eligible
                                            ? Icons.check_circle
                                            : Icons.error,
                                        color: state.eligible
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          state.message,
                                          style: TextStyle(
                                            color: state.eligible
                                                ? Colors.green.shade900
                                                : Colors.red.shade900,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>((
                                  Set<MaterialState> states,
                                ) {
                                  if (states.contains(MaterialState.disabled)) {
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
                              const EdgeInsets.symmetric(vertical: 20),
                            ),
                            elevation: MaterialStateProperty.all(4),
                          ),
                          onPressed:
                              (state is RegistrationEligibilityChecked &&
                                  state.eligible &&
                                  !(state is RegistrationLoading))
                              ? () => bloc.add(SubmitRegistration())
                              : null,
                          child: state is RegistrationLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Login',
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
