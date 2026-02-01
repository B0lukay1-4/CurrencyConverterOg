import 'dart:convert';
import 'package:flutter/material.dart';
import '../CurrencyDetail_Information/currency_conversion_rate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../CurrencyDetail_Information/currency_details.dart';

class Histroyrateinformation extends StatefulWidget {


  const Histroyrateinformation({super.key});

  @override
  _HistroyrateinformationState createState() => _HistroyrateinformationState();
}

class _HistroyrateinformationState extends State<Histroyrateinformation> {
  TextEditingController searchController = TextEditingController();
  TextEditingController yearController = TextEditingController(); 
  List<Currency_Conversion_rate> currencies = [];
  List<Currency_Conversion_rate> filteredCurrencies = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController currencyController = TextEditingController();
  String baseCurrency = "";
 

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

  const String apiKey = '027450ec162233010fb4df530456226f'; 

  
  String selectedDate = yearController.text.trim().isEmpty ? "2024-08-17" : yearController.text.trim();


  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(selectedDate)) {
    setState(() {
      isLoading = false;
      errorMessage = "Invalid date format. Use YYYY-MM-DD (e.g., 2024-08-17)";
    });
    return;
  }

  String apiUrl = "https://data.fixer.io/api/$selectedDate?access_key=$apiKey"; 
  
  try {
    final response = await http.get(Uri.parse(apiUrl));
    

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == false) { 
        throw Exception("API Error: ${data['error']['info']}");
      }

      if (data['rates'] == null || data['rates'].isEmpty) {
        throw Exception("No exchange rates found for $selectedDate.");
      }

      Map<String, dynamic> rates = data['rates'];

      double baseRate = rates[baseCurrency] ?? 1.0; 
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
        // Gradient Container with only header and input fields
        Padding(
          padding: const EdgeInsets.only(left: 5,right: 5),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
                bottom: Radius.circular(30),
              ),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1531A8),
                  Color(0xFF1E4AFF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "HistoryRateInformation",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      fontFamily:'SF Pro ' ,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    ),
                  ),
                ),
                // Base Currency Input Field
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text(
                        "Base :",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
              ],
                          ),
                          child: TextField(
                            controller: currencyController,
                            decoration: const InputDecoration(
                              hintText: "Enter base currency (e.g., USD)",
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) {
                              String newBaseCurrency = value.toUpperCase().trim();
                              if (newBaseCurrency.isNotEmpty) {
                                setState(() {
                                  baseCurrency = newBaseCurrency;
                                  isLoading = true;
                                });
                                _saveBaseCurrency(newBaseCurrency);
                                fetchCurrencies();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                    ],
                  ),
                ),
                // Date Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Text(
                        "Date :",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
              ],
                          ),
                          child: TextField(
                            controller: yearController,
                            keyboardType: TextInputType.datetime,
                            decoration: const InputDecoration(
                              hintText: "Enter date (e.g., 2024-08-17)",
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) {
                              fetchCurrencies();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // All cards (including the first one) in the ListView
        if (isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (errorMessage.isNotEmpty)
          Expanded(child: Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red))))
        else if (filteredCurrencies.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: filteredCurrencies.length, // Include all items
              itemBuilder: (context, index) {
                final currency = filteredCurrencies[index]; // Start from index 0
                String abbreviation = currency.abbreviation;
                double rate = currency.rate;

                String name = currency_details[abbreviation]?["name"] ?? abbreviation;
                String symbol = currency_details[abbreviation]?["symbol"] ?? "";

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
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
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$symbol ${rate.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          abbreviation,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
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