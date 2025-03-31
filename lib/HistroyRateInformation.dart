import 'dart:convert';
import 'package:flutter/material.dart';
import 'currency_conversion_rate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_details.dart';

class Histroyrateinformation extends StatefulWidget {
  final String searchQuery;

  const Histroyrateinformation({super.key, required this.searchQuery});

  @override
  _HistroyrateinformationState createState() => _HistroyrateinformationState();
}

class _HistroyrateinformationState extends State<Histroyrateinformation> {
  TextEditingController searchController = TextEditingController();
  TextEditingController yearController = TextEditingController(); // 🔹 New Controller for Year
  List<Currency_Conversion_rate> currencies = [];
  List<Currency_Conversion_rate> filteredCurrencies = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController currencyController = TextEditingController();
  String baseCurrency = "USD";
  String selectedYear = "2021"; // Default Year

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _loadBaseCurrency();
    fetchCurrencies();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterCurrencies();
  }

  Future<void> _loadBaseCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      baseCurrency = prefs.getString('base_currency') ?? "USD";
      currencyController.text = baseCurrency;
    });
  }

  Future<void> _saveBaseCurrency(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_currency', currency);
  }

Future<void> fetchCurrencies() async {  
  setState(() {
    isLoading = true;
    errorMessage = "";
  });

  const String apiKey = '027450ec162233010fb4df530456226f'; // Replace with your real API key

  // 🔹 Use default date if input is empty
  String selectedDate = yearController.text.trim().isEmpty ? "2024-08-17" : yearController.text.trim();

  // 🔹 Validate date format (YYYY-MM-DD)
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(selectedDate)) {
    setState(() {
      isLoading = false;
      errorMessage = "Invalid date format. Use YYYY-MM-DD (e.g., 2024-08-17)";
    });
    return;
  }

  String apiUrl = "https://data.fixer.io/api/$selectedDate?access_key=$apiKey"; 

  print("Fetching: $apiUrl"); // 🔵 Debugging: Print the API URL

  try {
    final response = await http.get(Uri.parse(apiUrl));
    print("API Response: ${response.body}"); // 🔵 Debugging: Print API response

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == false) { 
        throw Exception("API Error: ${data['error']['info']}");
      }

      if (data['rates'] == null || data['rates'].isEmpty) {
        throw Exception("No exchange rates found for $selectedDate.");
      }

      Map<String, dynamic> rates = data['rates'];

      // 🔹 Convert from EUR to selected base currency
      double baseRate = rates[baseCurrency] ?? 1.0; // Get base currency rate (or default to 1.0)
      Map<String, double> convertedRates = rates.map((key, value) => MapEntry(key, value / baseRate));

      List<Currency_Conversion_rate> fetchedCurrencies = convertedRates.entries
          .map((entry) => Currency_Conversion_rate(
                abbreviation: entry.key,
                rate: entry.value,
              ))
          .toList();

      setState(() {
        currencies = fetchedCurrencies;
        isLoading = false;
        _filterCurrencies();
      });
    } else {
      throw Exception("Failed to load data (HTTP ${response.statusCode})");
    }
  } catch (error) {
    setState(() {
      isLoading = false;
      errorMessage = "Error fetching currencies: ${error.toString()}";
    });
  }
}





  void _filterCurrencies() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredCurrencies = query.isEmpty
          ? List.from(currencies)
          : currencies.where((currency) {
              String abbreviation = currency.abbreviation.toLowerCase();
              String name =
                  currency_details[currency.abbreviation]?["name"]?.toLowerCase() ?? "";
              return abbreviation.contains(query) || name.contains(query);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const SizedBox(height: 40),

          // 🔵 Search Bar
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

          // 🔹 Base Currency Input and Year Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text("Base Currency:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: currencyController,
                      decoration: const InputDecoration(
                        hintText: "Only EUR available",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        String newBaseCurrency = value.toUpperCase().trim();
                        if (newBaseCurrency.isNotEmpty) {
                          setState(() {
                            baseCurrency = newBaseCurrency;
                          });
                          _saveBaseCurrency(newBaseCurrency);
                          fetchCurrencies();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Year Selector Input
 // 🔹 Full Date Input (Year-Month-Day)
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Row(
    children: [
      const Text("Date (YYYY-MM-DD):", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(width: 10),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: yearController, // 🔹 Now expects full date
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(
              hintText: "Enter date (e.g., 2024-08-17)",
              border: InputBorder.none,
            ),
            onSubmitted: (value) {
              fetchCurrencies(); // Fetch data when user submits date
            },
          ),
        ),
      ),
    ],
  ),
),


          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
                  : Expanded(
                      child: filteredCurrencies.isEmpty
                          ? const Center(child: Text("No matching currencies found"))
                          : ListView.builder(
                              itemCount: filteredCurrencies.length,
                              itemBuilder: (context, index) {
                                final currency = filteredCurrencies[index];
                                String abbreviation = currency.abbreviation;
                                double rate = currency.rate;

                                String name =
                                    currency_details[abbreviation]?["name"] ?? abbreviation;
                                String symbol =
                                    currency_details[abbreviation]?["symbol"] ?? "";

                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  color: Colors.white,
                                  elevation: 3,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16.0),
                                    leading: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.network(
                                        currency_details[abbreviation]?["image"] ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.money);
                                        },
                                      ),
                                    ),
                                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('$symbol ${rate.toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        Text(abbreviation, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
        ],
      ),
    );
  }
}
