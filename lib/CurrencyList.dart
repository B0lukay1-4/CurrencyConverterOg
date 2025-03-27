import 'package:currency_converter/AllPage.dart';
import 'package:currency_converter/SupportedPage.dart';
import 'package:flutter/material.dart';

class Currencylist extends StatefulWidget {
  const Currencylist({super.key});

  @override
  _CurrencylistState createState() => _CurrencylistState();
}

class _CurrencylistState extends State<Currencylist> {
  bool isAllSelected = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {}); // Ensures UI updates when text changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ),
          // Tab Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [ 
                  _buildTab("All", isAllSelected, true),
                  _buildTab("Supported", !isAllSelected, false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Page Content (Updating in real-time)
          Expanded(
            child: isAllSelected
                ? Allpage(searchQuery: searchController.text)
                : SupportedPage(searchQuery: searchController.text),
          ),
        ],
      ),
    );
  }

  // Function to create tab buttons
  Widget _buildTab(String text, bool isSelected, bool isLeft) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isAllSelected = isLeft;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
