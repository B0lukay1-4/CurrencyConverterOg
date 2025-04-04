import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // For RemoteNotification
import 'chart_analysis.dart'; // Adjust import path
import 'firebase_api.dart'; // Adjust import path

final List<Map<String, String>> availablePairs = [
  {"from": "USD", "to": "EUR"},
  {"from": "USD", "to": "JPY"},
  {"from": "USD", "to": "GBP"},
  {"from": "EUR", "to": "GBP"},
  {"from": "EUR", "to": "JPY"},
  {"from": "GBP", "to": "JPY"},
];

class CurrencyPairs extends StatefulWidget {
  const CurrencyPairs({super.key});

  @override
  _CurrencyPairsState createState() => _CurrencyPairsState();
}

class _CurrencyPairsState extends State<CurrencyPairs> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> filteredPairs = availablePairs;
  bool isLoading = false;
  Timer? _debounce;
  Timer? _rateCheckTimer;
  int requestsLeft = 25;
  DateTime? lastResetDate;
  double? rateLimit;
  String? monitoredPairFrom;
  String? monitoredPairTo;

  final String apiKey = dotenv.env['API_KEY'] ?? 'default_key';
  final FirebaseApi _firebaseApi = FirebaseApi(); // Instance for notifications

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterPairs);
    _loadRequestCounter();
    _loadRateLimit();
    _startRateMonitoring();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _rateCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRequestCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('last_reset_date');
    final savedRequests = prefs.getInt('requests_left') ?? 25;

    final now = DateTime.now();
    if (savedDate != null) {
      lastResetDate = DateTime.parse(savedDate);
      if (now.difference(lastResetDate!).inDays >= 1) {
        requestsLeft = 25;
        lastResetDate = now;
        await prefs.setString('last_reset_date', now.toIso8601String());
        await prefs.setInt('requests_left', 25);
      } else {
        requestsLeft = savedRequests;
      }
    } else {
      lastResetDate = now;
      await prefs.setString('last_reset_date', now.toIso8601String());
      await prefs.setInt('requests_left', 25);
    }
    setState(() {});
  }

  Future<void> _decrementRequestCounter() async {
    final prefs = await SharedPreferences.getInstance();
    requestsLeft = (prefs.getInt('requests_left') ?? 25) - 1;
    await prefs.setInt('requests_left', requestsLeft.clamp(0, 25));
    setState(() {});
  }

  Future<void> _loadRateLimit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rateLimit = prefs.getDouble('rateLimit');
    });
  }

  void _startRateMonitoring() {
    _rateCheckTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
      if (monitoredPairFrom != null &&
          monitoredPairTo != null &&
          rateLimit != null) {
        await _checkRate(monitoredPairFrom!, monitoredPairTo!);
      }
    });
  }

  Future<void> _checkRate(String fromCurrency, String toCurrency) async {
    if (requestsLeft <= 0) return;

    final realTimeUrl =
        "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=$fromCurrency&to_currency=$toCurrency&apikey=$apiKey";

    try {
      final response = await http.get(Uri.parse(realTimeUrl));
      final data = jsonDecode(response.body);
      final rateData = data["Realtime Currency Exchange Rate"];

      if (rateData != null) {
        double currentRate = double.parse(rateData["5. Exchange Rate"]);
        if (currentRate >= rateLimit!) {
          await _triggerNotification(fromCurrency, toCurrency, currentRate);
          await _decrementRequestCounter();
        }
      }
    } catch (e) {
      print("Rate check error: $e");
    }
  }

  Future<void> _triggerNotification(String from, String to, double rate) async {
    // Since _showLocalNotification is private, we'll need to make it public in FirebaseApi
    await _firebaseApi.showLocalNotification(RemoteNotification(
      title: "Rate Alert!",
      body: "$from/$to has reached $rate (your limit: $rateLimit)",
    ));
  }

  void _filterPairs() {
    final query = _searchController.text.toUpperCase();
    setState(() {
      filteredPairs = availablePairs
          .where((pair) =>
              "${pair['from']}/${pair['to']}".contains(query) ||
              "${pair['from']}${pair['to']}".contains(query))
          .toList();
    });
  }

  Future<void> _fetchPairData(String fromCurrency, String toCurrency) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (requestsLeft <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Daily request limit reached (25/25).")),
        );
        return;
      }

      final realTimeUrl =
          "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=$fromCurrency&to_currency=$toCurrency&apikey=$apiKey";
      final historicalUrl =
          "https://www.alphavantage.co/query?function=FX_DAILY&from_symbol=$fromCurrency&to_symbol=$toCurrency&outputsize=compact&apikey=$apiKey";

      try {
        setState(() => isLoading = true);
        await _decrementRequestCounter();

        final historicalResponse = await http.get(Uri.parse(historicalUrl));
        final historicalData = jsonDecode(historicalResponse.body);

        if (historicalData.containsKey("Error Message")) {
          throw Exception("API Error: ${historicalData["Error Message"]}");
        }
        if (historicalData.containsKey("Information")) {
          throw Exception("API Info: ${historicalData["Information"]}");
        }

        final timeSeries = historicalData["Time Series FX (Daily)"];
        List<Map<String, dynamic>> chartData = [];

        if (timeSeries != null) {
          timeSeries.forEach((date, values) {
            chartData.add({
              "date": date,
              "rate": double.parse(values["4. close"]),
            });
          });
          chartData = chartData.take(30).toList();
        } else {
          throw Exception(
              "Historical data not available. Response: ${jsonEncode(historicalData)}");
        }

        final realTimeResponse = await http.get(Uri.parse(realTimeUrl));
        final realTimeData = jsonDecode(realTimeResponse.body);
        final rateData = realTimeData["Realtime Currency Exchange Rate"];

        if (rateData != null) {
          final newRate = {
            "date": rateData["6. Last Refreshed"],
            "rate": double.parse(rateData["5. Exchange Rate"]),
          };
          chartData.add(newRate);
          if (chartData.length > 30) chartData.removeAt(0);

          final pairData = {
            "fromCurrency": rateData["1. From_Currency Code"],
            "toCurrency": rateData["3. To_Currency Code"],
            "exchangeRate": double.parse(rateData["5. Exchange Rate"]),
            "lastRefreshed": rateData["6. Last Refreshed"],
            "chartData": chartData,
          };

          monitoredPairFrom = fromCurrency;
          monitoredPairTo = toCurrency;

          setState(() => isLoading = false);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChartAnalysis(
                pairData: pairData,
                onFetchData: _fetchPairData,
              ),
            ),
          );
        } else {
          throw Exception(
              "Real-time data not available. Response: ${jsonEncode(realTimeData)}");
        }
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), duration: Duration(seconds: 5)),
        );
      }
    });
  }

  void _onSearchSubmitted(String value) {
    final parts = value.split('/').map((p) => p.trim().toUpperCase()).toList();
    if (parts.length == 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      _fetchPairData(parts[0], parts[1]);
      _searchController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Invalid format. Use 'FROM/TO' (e.g., USD/EUR)")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Currency Pair Search"),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Requests Left: $requestsLeft/25",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Search or Enter Pair (e.g., USD/EUR)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: _onSearchSubmitted,
                ),
              ),
              Expanded(
                child: filteredPairs.isEmpty &&
                        _searchController.text.isNotEmpty
                    ? Center(child: Text("No matching pairs found in list"))
                    : ListView.builder(
                        itemCount: filteredPairs.length,
                        itemBuilder: (context, index) {
                          final pair = filteredPairs[index];
                          final pairString = "${pair['from']}/${pair['to']}";
                          return ListTile(
                            title: Text(pairString),
                            onTap: () {
                              _searchController.clear();
                              _fetchPairData(pair["from"]!, pair["to"]!);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
