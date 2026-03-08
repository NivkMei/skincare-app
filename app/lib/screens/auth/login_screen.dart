import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LoginScreen(),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();

  bool _obscureLogin = true;
  bool _obscureRegister = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in [_emailCtrl, _passCtrl, _nameCtrl, _regEmailCtrl, _regPassCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _login(BuildContext ctx) async {
    if (!_loginFormKey.currentState!.validate()) return;
    final auth = ctx.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!ctx.mounted) return;
    if (ok) {
      // Sync favorites after login
      await ctx.read<FavoritesProvider>().onAuthChanged(isLoggedIn: true);
      if (!ctx.mounted) return;
      Navigator.of(ctx).pop();
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Welcome back, ${auth.userName}!')),
      );
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _register(BuildContext ctx) async {
    if (!_registerFormKey.currentState!.validate()) return;
    final auth = ctx.read<AuthProvider>();
    final ok = await auth.register(
      _nameCtrl.text.trim(),
      _regEmailCtrl.text.trim(),
      _regPassCtrl.text,
    );
    if (!ctx.mounted) return;
    if (ok) {
      await ctx.read<FavoritesProvider>().onAuthChanged(isLoggedIn: true);
      if (!ctx.mounted) return;
      Navigator.of(ctx).pop();
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Welcome, ${auth.userName}!')),
      );
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('My Account',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabs,
              tabs: const [Tab(text: 'Log In'), Tab(text: 'Sign Up')],
              labelColor: cs.primary,
              indicatorColor: cs.primary,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _buildLoginTab(auth),
                  _buildRegisterTab(auth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab(AuthProvider auth) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscureLogin,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureLogin
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscureLogin = !_obscureLogin),
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter your password' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: auth.isLoading ? null : () => _login(context),
              child: auth.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTab(AuthProvider auth) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _regEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _regPassCtrl,
              obscureText: _obscureRegister,
              decoration: InputDecoration(
                labelText: 'Password (min. 6 chars)',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureRegister
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscureRegister = !_obscureRegister),
                ),
              ),
              validator: (v) =>
                  v == null || v.length < 6 ? 'At least 6 characters' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: auth.isLoading ? null : () => _register(context),
              child: auth.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
