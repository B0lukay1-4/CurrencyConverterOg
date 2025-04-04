import 'package:currency_converter/CurrencyNews%20and%20Market%20Trends/news_page.dart';
import 'package:currency_converter/UserSettings/user_profile.dart';
import 'package:currency_converter/components/ConverterPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// Home page of the app, serving as entry point and navigation hub
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Pages available for all users (placeholders for lazy loading)
  static final List<Widget> _pages = [
    _HomeContent(), // Custom home content
    SizedBox(), // Placeholder for NewsPage
    ConverterPage(), // Placeholder for Converter page
    UserProfile(), // Settings page accessible to all
  ];

  // Updates the selected index when a bottom nav item is tapped
  void _navigateBottomBar(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Dynamically loads pages based on index
  Widget getPage(int index) {
    if (index == 1) return NewsPage(); // Load NewsPage on demand
    return _pages[index];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading authentication state')),
          );
        }

        // Determine if user is authenticated
        final bool isAuthenticated = snapshot.hasData;

        // Navigation items (Profile/Settings always visible)
        final navItems = [
          const GButton(icon: Icons.home, text: 'Home'),
          const GButton(icon: Icons.newspaper, text: 'News'),
          const GButton(icon: Icons.currency_exchange, text: 'Converter'),
          const GButton(icon: Icons.person, text: 'Settings'),
        ];

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Text('Currency Converter'), // Static title
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: List.generate(
              _pages.length,
              (index) => getPage(index),
            ),
          ),
          bottomNavigationBar: Container(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: GNav(
                backgroundColor: Colors.black,
                color: Colors.white,
                activeColor: Colors.white,
                tabBackgroundColor: Colors.grey.shade800,
                gap: 8,
                padding: const EdgeInsets.all(16),
                tabs: navItems,
                selectedIndex: _selectedIndex,
                onTabChange: _navigateBottomBar,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom home content widget for the Home tab
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/Currency.png',
            height: 210,
            width: 210,
          ),
          const SizedBox(height: 20),
          const Text(
            'Currency Converter',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Explore currency news and conversions!',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
