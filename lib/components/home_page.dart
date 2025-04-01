import 'package:currency_converter/CurrencyNews%20and%20Market%20Trends/news_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_authentication/login_or_register.dart';

// Home page with bottom navigation for different screens
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Current selected tab index
  int _selectedIndex = 0;

  // Username displayed in the AppBar, defaults to "Guest"
  String _username = "Guest";

  // List of pages for navigation (avoid recursive HomePage reference)
  static const List<Widget> _pages = [
    Center(child: Text("Home Screen")), // Placeholder for Home
    Center(child: Text("Exchange Screen")), // Placeholder for Exchange
    Center(child: Text("History Screen")), // Placeholder for History
    NewsPage(), // News page from your app
    Center(child: Text("Profile Screen")), // Placeholder for Profile
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsername(); // Fetch username when the widget initializes
  }

  // Fetches the username from FirebaseAuth for the logged-in user
  void _fetchUsername() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _username = user.displayName ??
            user.email?.split('@')[0] ??
            "User"; // Fallbacks: displayName > email prefix > "User"
      });
    }
  }

  // Checks if a user is currently logged in
  bool _isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  // Handles bottom navigation tab changes
  void _navigateBottomBar(int index) {
    if (index != 0 && !_isUserLoggedIn()) {
      // Redirect to login if user is not authenticated (except Home tab)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
      );
    } else if (_selectedIndex != index) {
      // Update index only if it’s different to avoid unnecessary rebuilds
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome $_username"), // Dynamic username in title
        elevation: 2, // Slight shadow for depth
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: _navigateBottomBar,
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(icon: Icons.home_filled, text: "Home"),
              GButton(icon: Icons.currency_exchange, text: "Exchange"),
              GButton(icon: Icons.history, text: "History"),
              GButton(icon: Icons.newspaper_sharp, text: "News"),
              // GButton(icon: Icons.person, text: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}
