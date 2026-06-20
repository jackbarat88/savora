import 'package:flutter/material.dart';

import '/repositories/category_repository.dart';
import '/repositories/transaction_repository.dart';
import '/repositories/user_repository.dart';
import '/screens/category_screen.dart';
import '/screens/dashboard_screen.dart';
import '/screens/login_screen.dart';
import '/screens/register_screen.dart';
import '/screens/report_screen.dart';
import '/screens/transaction_screen.dart';
import '/services/auth_service.dart';
import '/services/finance_service.dart';
import '/session/user_session.dart';
import '/widgets/responsive_scaffold.dart';

class SavoraApp extends StatelessWidget {
  const SavoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B5B),
          primary: const Color(0xFF176B5B),
          secondary: const Color(0xFF2563A9),
          tertiary: const Color(0xFFE58B3A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F7F6),
          foregroundColor: Color(0xFF17211F),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE2E8E6)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD8E1DE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD8E1DE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF176B5B), width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE2F1ED),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final UserSession _session;
  late final AuthService _authService;
  late final FinanceService _financeService;
  late final UserRepository _userRepository;
  late final CategoryRepository _categoryRepository;
  late final TransactionRepository _transactionRepository;

  bool _showRegister = false;

  @override
  void initState() {
    super.initState();
    _session = UserSession();
    _userRepository = UserRepository();
    _categoryRepository = CategoryRepository();
    _transactionRepository = TransactionRepository();
    _authService = AuthService(_userRepository, _session);
    _financeService = FinanceService();
  }

  void _onAuthChanged() {
    setState(() {
      _showRegister = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_session.isLoggedIn) {
      return _MainScreen(
        fullName: _session.currentUser!.fullName,
        userId: _session.currentUser!.id,
        authService: _authService,
        financeService: _financeService,
        categoryRepository: _categoryRepository,
        transactionRepository: _transactionRepository,
        onLogout: () {
          _authService.logout();
          _onAuthChanged();
        },
      );
    }

    if (_showRegister) {
      return RegisterScreen(
        authService: _authService,
        onRegistered: () => setState(() => _showRegister = false),
        goToLogin: () => setState(() => _showRegister = false),
      );
    }

    return LoginScreen(
      authService: _authService,
      onLoginSuccess: _onAuthChanged,
      goToRegister: () => setState(() => _showRegister = true),
    );
  }
}

class _MainScreen extends StatefulWidget {
  final String fullName;
  final String userId;
  final AuthService authService;
  final FinanceService financeService;
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;
  final VoidCallback onLogout;

  const _MainScreen({
    required this.fullName,
    required this.userId,
    required this.authService,
    required this.financeService,
    required this.categoryRepository,
    required this.transactionRepository,
    required this.onLogout,
  });

  @override
  State<_MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {
  int _index = 0;
  final _dashboardKey = GlobalKey<DashboardScreenState>();

  static const _titles = ['Beranda', 'Transaksi', 'Kategori', 'Laporan'];

  void _onSelect(int i) {
    if (i == 0 && _index != 0) {
      _dashboardKey.currentState?.refresh();
    }
    setState(() => _index = i);
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Anda akan keluar dari akun ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      widget.onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(
        key: _dashboardKey,
        userId: widget.userId,
        fullName: widget.fullName,
        transactionRepository: widget.transactionRepository,
        financeService: widget.financeService,
        onTransactionTap: () => _onSelect(1),
      ),
      TransactionScreen(
        userId: widget.userId,
        transactionRepository: widget.transactionRepository,
        categoryRepository: widget.categoryRepository,
      ),
      CategoryScreen(
        userId: widget.userId,
        categoryRepository: widget.categoryRepository,
      ),
      ReportScreen(
        userId: widget.userId,
        transactionRepository: widget.transactionRepository,
        financeService: widget.financeService,
      ),
    ];

    return ResponsiveScaffold(
      title: _titles[_index],
      selectedIndex: _index,
      onDestinationSelected: _onSelect,
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmLogout,
        tooltip: 'Keluar',
        child: const Icon(Icons.logout),
      ),
    );
  }
}
