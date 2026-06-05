import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/auth_controller.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Auth Demo')),
      body: Center(
        child: state.isLoading
            ? const CircularProgressIndicator()
            : state.user != null
                ? Text('Welcome ${state.user!.name}')
                : state.error != null
                    ? Text(state.error!)
                    : ElevatedButton(
                        onPressed: () => ref
                            .read(authControllerProvider.notifier)
                            .login('demo@mail.com', '123456'),
                        child: const Text('Login'),
                      ),
      ),
    );
  }
}
