import 'package:flutter/material.dart';

import '/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLoginSuccess;
  final VoidCallback goToRegister;

  const LoginScreen({
    super.key,
    required this.authService,
    required this.onLoginSuccess,
    required this.goToRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final user = await widget.authService.login(
      username: _usernameCtrl.text,
      password: _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (user != null) {
      widget.onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 820;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: wide
                ? Row(
                    children: [
                      Expanded(child: _BrandPanel(compact: !wide)),
                      const SizedBox(width: 24),
                      SizedBox(width: 390, child: _loginPanel(context)),
                    ],
                  )
                : _loginPanel(context),
          ),
        ),
      ),
    );
  }

  Widget _loginPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E8E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _BrandPanel(compact: true),
            const SizedBox(height: 24),
            TextFormField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Data tidak boleh kosong.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Data tidak boleh kosong.' : null,
              onFieldSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Masuk'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum punya akun? '),
                TextButton(
                  onPressed: widget.goToRegister,
                  child: const Text('Daftar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  final bool compact;

  const _BrandPanel({required this.compact});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(compact ? 0 : 32),
      decoration: compact
          ? null
          : BoxDecoration(
              color: const Color(0xFF0F2F2A),
              borderRadius: BorderRadius.circular(8),
            ),
      child: Column(
        crossAxisAlignment:
            compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 54 : 62,
            height: compact ? 54 : 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: compact ? primary : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: compact ? Colors.white : const Color(0xFFBFE6D7),
              size: compact ? 28 : 32,
            ),
          ),
          SizedBox(height: compact ? 14 : 24),
          Text(
            'Savora',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: compact ? const Color(0xFF17211F) : Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Catatan keuangan pribadi untuk mahasiswa.',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: compact
                  ? Colors.grey.shade600
                  : Colors.white.withValues(alpha: 0.78),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
