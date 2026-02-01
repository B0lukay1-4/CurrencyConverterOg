import 'package:currency_converter/CurrencyPages/AllCurrencyList.dart'; 
import 'package:currency_converter/CurrencyPages/SupportedCurrencyList.dart';
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Gradient Header (NO BOTTOM RADIUS)
          Padding(
             padding: const EdgeInsets.only(left: 5,right: 5),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E4AFF), Color(0xFF1531A8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), // Adjust the radius as needed
                  topRight: Radius.circular(30), // Adjust the radius as needed
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
              ],
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
                  // Toggle Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Row(
              children: [
                _buildTab("All", isAllSelected, true),
                _buildTab("Supported", !isAllSelected, false),
              ],
            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          // Page Content (ENSURES IT DOESN’T GET CUT OFF)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10), // Prevents cutoff
              child: isAllSelected
                  ? Allpage(searchQuery: searchController.text)
                  : SupportedPage(searchQuery: searchController.text),
            ),
          ),
        ],
      ),
    );
  }

  // Function to create tabs
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
            gradient: isSelected
                ? LinearGradient(
                    colors: [Color(0xFF1E4AFF), Color(0xFF1531A8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                : [],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
