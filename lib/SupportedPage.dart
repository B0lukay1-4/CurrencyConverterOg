import 'package:flutter/material.dart';   
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'currency_conversion_rate.dart';
import 'currency_details.dart';
class SupportedPage extends StatefulWidget {
  final String searchQuery;

  const SupportedPage({super.key, required this.searchQuery});

  @override
  _SupportedPageState createState() => _SupportedPageState();
}

class _SupportedPageState extends State<SupportedPage> {
  List<Currency_Conversion_rate> supportedCurrencies = [];
  List<Currency_Conversion_rate> filteredCurrencies = [];
  TextEditingController currencyController = TextEditingController();
  String baseCurrency = "USD"; // Default base currency
  bool isLoading = true;
  bool hasError = false;

  

  final List<String> selectedCurrencies = ["USD", "EUR", "GBP", "JPY", "AUD", "CHF"];

  @override
  void initState() {
    super.initState();
    _loadBaseCurrency();
  }

  @override
  void didUpdateWidget(covariant SupportedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterCurrencies();
    }
  }

  Future<void> _loadBaseCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      baseCurrency = prefs.getString('base_currency') ?? "USD";
      currencyController.text = baseCurrency;
    });
    _fetchExchangeRates();
  }

  Future<void> _saveBaseCurrency(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_currency', currency);
  }

  Future<void> _fetchExchangeRates() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    const String apiKey = "4780d252b323e214c313c0ac"; // Replace with your actual API key
    final String url = "https://v6.exchangerate-api.com/v6/$apiKey/latest/$baseCurrency";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["result"] == "success") {
          Map<String, dynamic> rates = data["conversion_rates"];

          setState(() {
            supportedCurrencies = selectedCurrencies.map((currency) {
              return Currency_Conversion_rate(
                abbreviation: currency,
                rate: rates[currency]?.toDouble() ?? 0.0,
              );
            }).toList();

            _filterCurrencies();
          });
        } else {
          print("API Error: ${data["error-type"]}");
          setState(() => hasError = true);
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        setState(() => hasError = true);
      }
    } catch (e) {
      print("Exception: $e");
      setState(() => hasError = true);
    }

    setState(() => isLoading = false);
  }


  void _filterCurrencies() {
    String query = widget.searchQuery.toLowerCase();
    setState(() {
      filteredCurrencies = query.isEmpty
          ? List.from(supportedCurrencies)
          : supportedCurrencies.where((currency) {
              String abbreviation = currency.abbreviation.toLowerCase();
              String name = currency_details[currency.abbreviation]?["name"]?.toLowerCase() ?? "";
              return abbreviation.contains(query) || name.contains(query);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
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
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: currencyController,
                    decoration: const InputDecoration(
                      hintText: "Enter base currency (e.g., USD)",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      String newBaseCurrency = value.toUpperCase().trim();
                      if (newBaseCurrency.isNotEmpty && selectedCurrencies.contains(newBaseCurrency)) {
                        setState(() {
                          baseCurrency = newBaseCurrency;
                        });
                        _saveBaseCurrency(newBaseCurrency);
                        _fetchExchangeRates(); // Refresh rates
                      } else {
                        print("Invalid currency entered");
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

      
        if (isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (hasError)
          const Expanded(child: Center(child: Text("Failed to fetch exchange rates. Try again later.")))
        else
          Expanded(
            child: filteredCurrencies.isEmpty
                ? const Center(child: Text("No matching currencies found"))
                : ListView.builder(
                    itemCount: filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = filteredCurrencies[index];
                      final details = currency_details[currency.abbreviation] ?? {"name": "Unknown", "symbol": ""};

                   return Card(
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  color: const Color.fromARGB(255, 255, 255, 255),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 3,
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
    
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                currency_details[currency.abbreviation]?["image"] ?? '',
                width: 40,
                height: 30,
                fit: BoxFit.contain, 
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.money, size: 30, color: Colors.grey);
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              details['name'] ?? "Unknown",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${details['symbol'] ?? ''} ${currency.rate.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currency.abbreviation,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
                    },
                  ),
          ),
      ],
    );
  }
}
