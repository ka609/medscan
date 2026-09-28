import 'package:flutter/material.dart';

import 'home_screen.dart';

// Écran principal avec navigation par onglets.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const Color _primary = Color(0xFF1565C0);
  static const Color _textMuted = Color(0xFF6B7280);

  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    _PlaceholderScreen(title: 'Rendez-vous'),
    _PlaceholderScreen(title: 'Messages'),
    _PlaceholderScreen(title: 'Profil'),
  ];

  // Change d'onglet.
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: _primary,
            unselectedItemColor: _textMuted,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month),
                label: 'Rendez-vous',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined),
                activeIcon: Icon(Icons.message),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Écran temporaire.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: _MainScreenState._primary,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Écran "$title" à venir',
          style: const TextStyle(
            fontSize: 15,
            color: _MainScreenState._textMuted,
          ),
        ),
      ),
    );
  }
}