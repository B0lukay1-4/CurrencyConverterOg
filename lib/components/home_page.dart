// File: lib/components/home_page.dart
import 'package:currency_converter/CurrencyNews%20and%20Market%20Trends/news_page.dart';
import 'package:currency_converter/UserSettings/user_profile.dart';
import 'package:currency_converter/user_authentication/login_or_register.dart';
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
  // Current index of the selected bottom navigation item
  int _selectedIndex = 0;

  // Pages available for all users (Home is a custom widget)
  static const List<Widget> _basePages = [
    _HomeContent(), // Custom home content
    NewsPage(),
    Placeholder(), // Placeholder for Converter page
  ];

  // Pages including profile for authenticated users
  static const List<Widget> _authenticatedPages = [
    _HomeContent(), // Custom home content
    NewsPage(),
    Placeholder(), // Placeholder for Converter page
    UserProfile(), // Separate profile page
  ];

  // Updates the selected index when a bottom nav item is tapped
  void _navigateBottomBar(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Logs out the current user
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // UI will update via StreamBuilder
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while auth state is being determined
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle auth stream errors
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading authentication state')),
          );
        }

        // Determine if user is authenticated and get username
        final bool isAuthenticated = snapshot.hasData;
        // final String welcomeText = isAuthenticated
        //     ? 'Welcome ${snapshot.data!.displayName ?? 'User'}'
        //     : 'Welcome Guest';

        // Choose pages and nav items based on auth status
        final pages = isAuthenticated ? _authenticatedPages : _basePages;
        final navItems = [
          const GButton(icon: Icons.home, text: 'Home'),
          const GButton(icon: Icons.newspaper, text: 'News'),
          const GButton(icon: Icons.currency_exchange, text: 'Converter'),
          if (isAuthenticated)
            const GButton(icon: Icons.person, text: 'Profile'),
        ];

        return Scaffold(
          appBar: AppBar(
            // title: Text(welcomeText),
            elevation: 0, // Slight shadow for depth
            actions: [
              if (!isAuthenticated)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginOrRegister()),
                      );
                    },
                    child: const Text('Login'),
                  ),
                ),
              if (isAuthenticated)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ElevatedButton(
                    onPressed: _logout,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Logout'),
                  ),
                ),
            ],
          ),
          body: pages[_selectedIndex],
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
