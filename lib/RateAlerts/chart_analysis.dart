import 'dart:async';
import 'package:currency_converter/RateAlerts/firebase_api.dart';
import 'package:currency_converter/UserSettings/user_notification_settings.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChartAnalysis extends StatefulWidget {
  final Map<String, dynamic> pairData;
  final Future<void> Function(String, String) onFetchData;

  const ChartAnalysis({
    super.key,
    required this.pairData,
    required this.onFetchData,
  });

  @override
  _ChartAnalysisState createState() => _ChartAnalysisState();
}

class _ChartAnalysisState extends State<ChartAnalysis> {
  double? selectedRate;
  final FirebaseApi _firebaseApi = FirebaseApi();
  bool _rateAlertsEnabled = true;
  bool isLoading = false;

  final String apiKey = dotenv.env['API_KEY'] ?? 'default_key';
  final String fcmServerKey = dotenv.env['FCM_SERVER_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _firebaseApi.initNotifications();
    _loadPreferences();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rateAlertsEnabled = prefs.getBool('rateAlertsEnabled') ?? true;
    });
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    try {
      await widget.onFetchData(
          widget.pairData['fromCurrency'], widget.pairData['toCurrency']);
      if (_rateAlertsEnabled) {
        _checkRateAlert();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _checkRateAlert() {
    if (selectedRate != null) {
      final currentRate = widget.pairData['exchangeRate'] as double;
      if ((currentRate >= selectedRate! &&
              currentRate - selectedRate! < 0.01) ||
          (currentRate <= selectedRate! &&
              selectedRate! - currentRate < 0.01)) {
        _sendNotification();
        setState(() {
          selectedRate = null;
        });
      }
    }
  }

  Future<void> _sendNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final rateAlertsEnabled = prefs.getBool('rateAlertsEnabled') ?? true;

    if (!rateAlertsEnabled || fcmServerKey.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final message = {
        'notification': {
          'title':
              'Rate Alert: ${widget.pairData['fromCurrency']}/${widget.pairData['toCurrency']}',
          'body': 'The exchange rate has reached your target of $selectedRate',
        },
        'to': '/topics/${user.uid}',
      };

      try {
        final response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$fcmServerKey',
          },
          body: jsonEncode(message),
        );
        if (response.statusCode != 200) {
          throw Exception('FCM request failed: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending notification: $e')),
        );
      }
    }
  }

  void _setRateAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Rate Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tap the chart or enter a target rate'),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Target Rate',
                hintText: selectedRate?.toStringAsFixed(4) ?? 'Enter rate',
              ),
              onChanged: (value) {
                setState(() {
                  selectedRate = double.tryParse(value);
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedRate != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rate alert set for $selectedRate')),
                );
                Navigator.pop(context);
              }
            },
            child: Text('Set Alert'),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserNotificationSettings()),
    ).then((_) => _loadPreferences());
  }

  @override
  Widget build(BuildContext context) {
    final chartData = widget.pairData["chartData"] as List;
    final minY = chartData
            .map((e) => e["rate"] as double)
            .reduce((a, b) => a < b ? a : b) *
        0.95;
    final maxY = chartData
            .map((e) => e["rate"] as double)
            .reduce((a, b) => a > b ? a : b) *
        1.05;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${widget.pairData['fromCurrency']}/${widget.pairData['toCurrency']}"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: 'Notification Settings',
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${widget.pairData['fromCurrency']}/${widget.pairData['toCurrency']}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${widget.pairData['exchangeRate'].toStringAsFixed(4)}",
                      style: TextStyle(fontSize: 20, color: Colors.green),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text("Last Refreshed: ${widget.pairData['lastRefreshed']}"),
                SizedBox(height: 16),
                Text("Live Chart (Last 30 Days)",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: GestureDetector(
                    onTapUp: (details) {
                      final RenderBox box =
                          context.findRenderObject() as RenderBox;
                      final localPosition =
                          box.globalToLocal(details.globalPosition);
                      final chartHeight = box.size.height;
                      final yRange = maxY - minY;
                      final tappedRate =
                          maxY - (localPosition.dy / chartHeight) * yRange;
                      setState(() {
                        selectedRate =
                            double.parse(tappedRate.toStringAsFixed(4));
                      });
                      _setRateAlert();
                    },
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 ||
                                    index >= chartData.length ||
                                    index % 5 != 0) {
                                  return const SizedBox
                                      .shrink(); // hide some labels for clarity
                                }
                                final date =
                                    chartData[index]["date"].split('-');
                                return Text(
                                  "${date[1]}-${date[2]}", // format MM-DD
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(2),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        minY: minY,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: chartData
                                .asMap()
                                .entries
                                .map((e) =>
                                    FlSpot(e.key.toDouble(), e.value["rate"]))
                                .toList(),
                            isCurved: true,
                            color: Colors.blue,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                        extraLinesData: selectedRate != null
                            ? ExtraLinesData(
                                horizontalLines: [
                                  HorizontalLine(
                                    y: selectedRate!,
                                    color: Colors.red,
                                    strokeWidth: 2,
                                    dashArray: [5, 5],
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _setRateAlert,
                      child: const Text('Set Rate Alert'),
                    ),
                    ElevatedButton(
                      onPressed: _navigateToSettings,
                      child: const Text('Notification Settings'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        tooltip: 'Refresh Data',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
