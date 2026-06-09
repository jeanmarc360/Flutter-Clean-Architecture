import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/auth_controller.dart';

class ScreenLogin extends ConsumerWidget {
  const ScreenLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Auth Demo')),
      body: Center(
        child: state.isLoading
            ? const CircularProgressIndicator()
            : state.authToken != null
                ? Text('Access token: ${state.authToken!.accessToken}')
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
