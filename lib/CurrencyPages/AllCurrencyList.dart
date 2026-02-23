import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../CurrencyDetail_Information/currency_conversion_rate.dart';
import 'package:http/http.dart' as http;
import '../CurrencyDetail_Information/currency_details.dart';

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
  String baseCurrency = "USD";

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

  // Get the path to the file

  Future<String> _getFilePath() async {
    final directory = await Directory.systemTemp.createTemp();
    return '${directory.path}/base_currency.txt';
  }

  Future<void> _writeBaseCurrencyToFile(String currency) async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      await file.writeAsString(currency);
    } catch (e) {
      print("Error writing currency: $e");
    }
  }

  Future<void> _loadBaseCurrency() async {
    try {
      final path = await _getFilePath();
      final file = File(path);

      if (await file.exists()) {
        String savedCurrency = await file.readAsString();
        setState(() {
          baseCurrency = savedCurrency;
          currencyController.text = savedCurrency;
        });
      }
    } catch (e) {
      print("Error loading currency: $e");
    }
  }

  Future<void> _saveBaseCurrency(String currency) async {
    final path = await _getFilePath();
    final file = File(path);
    await file.writeAsString(currency);

    setState(() {
      baseCurrency = currency;
      currencyController.text = currency;
    });

    fetchCurrencies();
  }

  Future<void> fetchCurrencies() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.exchangerate-api.com/v4/latest/$baseCurrency'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> rates = data['rates'];
        List<Currency_Conversion_rate> fetchedCurrencies =
            rates.entries.map((entry) {
          return Currency_Conversion_rate(
              abbreviation: entry.key, rate: entry.value.toDouble());
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
              String name = currency_details[currency.abbreviation]?["name"]
                      ?.toLowerCase() ??
                  "";
              return abbreviation.contains(query) || name.contains(query);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Blue gradient container with Base Currency Input
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 156, 17, 172), // Deep plum (dark end)
                  Color(0xFF8E4585), // Medium-dark plum (light-ish end)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Base Currency Input Field
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Text(
                        "Base :",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .white, // White text to match the blue background
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                          width: 8), // Space between "Base :" and input field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2))
                            ],
                          ),
                          child: TextField(
                            controller: currencyController,
                            decoration: const InputDecoration(
                              hintText: "Enter Base Currency (e.g., USD)",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                            ),
                            onSubmitted: (value) async {
                              if (value.isNotEmpty) {
                                String currency = value.toUpperCase().trim();
                                await _writeBaseCurrencyToFile(
                                    currency); // Save to file
                                setState(() {
                                  baseCurrency = currency;
                                });
                                fetchCurrencies(); // Refresh currencies
                              }
                            },
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // Currency List
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Text(errorMessage,
                          style: const TextStyle(color: Colors.red)))
                  : filteredCurrencies.isEmpty
                      ? const Center(
                          child: Text("No matching currencies found"))
                      : ListView.builder(
                          itemCount: filteredCurrencies.length,
                          itemBuilder: (context, index) {
                            final currency = filteredCurrencies[index];
                            String abbreviation = currency.abbreviation;
                            double rate = currency.rate;

                            // Fetch name & symbol from external map
                            String name = currency_details[abbreviation]
                                    ?["name"] ??
                                abbreviation;
                            String symbol =
                                currency_details[abbreviation]?["symbol"] ?? "";

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: const Color.fromARGB(255, 255, 255, 255),
                              elevation: 3,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.network(
                                      currency_details[abbreviation]
                                              ?["image"] ??
                                          '',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.money);
                                      },
                                    ),
                                  ),
                                ),
                                title: Text(
                                  name.isNotEmpty ? name : abbreviation,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$symbol ${rate.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      abbreviation,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
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
