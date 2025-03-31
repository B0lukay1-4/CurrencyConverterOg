import 'dart:convert';
import 'package:flutter/material.dart';
import 'currency_conversion_rate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_details.dart'; 

class Allpage extends StatefulWidget {
  final String searchQuery;

  const Allpage({super.key, required this.searchQuery});

  @override
  _AllpageState createState() => _AllpageState();
}

class _AllpageState extends State<Allpage> {
  List<Currency_Conversion_rate> currencies = [];
  List<Currency_Conversion_rate> filteredCurrencies = [];
  bool isLoading = true;
  String errorMessage = '';
  TextEditingController currencyController = TextEditingController();
  String baseCurrency = "USD"; // Default base currency

  @override
  void initState() {
    super.initState();
    _loadBaseCurrency();
    fetchCurrencies();
  }

  @override
  void didUpdateWidget(covariant Allpage oldWidget) {
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
  }

  Future<void> _saveBaseCurrency(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_currency', currency);
  }

  Future<void> fetchCurrencies() async {
    try {
      final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/$baseCurrency'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> rates = data['rates'];

        List<Currency_Conversion_rate> fetchedCurrencies = rates.entries.map((entry) {
          return Currency_Conversion_rate(abbreviation: entry.key, rate: entry.value.toDouble());
        }).toList();

        setState(() {
          currencies = fetchedCurrencies;
          isLoading = false;
          _filterCurrencies();
        });
      } else {
        throw Exception("Failed to load currencies");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = "Error fetching currencies: ${error.toString()}";
      });
    }
  }

  void _filterCurrencies() {
    String query = widget.searchQuery.toLowerCase();
    setState(() {
      filteredCurrencies = query.isEmpty
          ? List.from(currencies)
          : currencies.where((currency) {
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
        // Base Currency Input Field
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
                    color: const Color.fromARGB(255, 255, 253, 253),
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
              SizedBox(width: 9,),
              OutlinedButton(
          onPressed: () {
            print("");
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.grey[300], // Light gray background
            foregroundColor: Colors.black, // Black text color
            side: BorderSide(color: Colors.grey[400]!, width: 1.5), // Thin border
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Slightly rounded corners
            ),
          ),
          child: Text("Remember", style: TextStyle(fontSize: 16)),
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

                              // Fetch name & symbol from external map
                              String name = currency_details[abbreviation]?["name"] ?? abbreviation;
                              String symbol = currency_details[abbreviation]?["symbol"] ?? "";

                             return Card(
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  color: const Color.fromARGB(255, 255, 255, 255),
  elevation: 3,
  child: ListTile(
    contentPadding: const EdgeInsets.all(16.0),

    // 👇 Load image from the map
    leading: SizedBox(
      width: 40,
      height: 40,
      child: Image.network(
        currency_details[abbreviation]?["image"] ?? '', // fallback if key missing
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.money); // fallback icon
        },
      ),
    ),

    title: Text(
      name.isNotEmpty ? name : abbreviation,
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
    );
  }
}
