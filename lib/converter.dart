import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:currency_converter/currencyDetails.dart';
import 'package:currency_converter/widgets/drop_down.dart';
import 'package:currency_converter/services/api_client.dart';
import 'package:currency_converter/screens/conversion_history.dart'; // Import the history screen

class Converter extends StatefulWidget {
  const Converter({super.key});

  @override
  State<Converter> createState() => _ConverterState();
}

class _ConverterState extends State<Converter> {
  ApiClient Client = ApiClient();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Color mainColor = Color.fromARGB(255, 255, 255, 255);
  Color secondColor = Color.fromARGB(255, 52, 89, 238);
  List<String> currencies = [];

  String from = "USD";
  String to = "EUR";
  double rate = 1.0;
  String result = "";
  String inputValue = "1"; // Default input value

  @override
  void initState() {
    super.initState();
    (() async {
      List<String> list = await Client.getCurrencies();
      setState(() {
        currencies = list;
      });
    })();
  }

  Future<void> saveConversion(String from, String to, double amount, double rate, double result) async {
    await firestore.collection("conversionHistory").add({
      "from": from,
      "to": to,
      "amount": amount,
      "rate": rate,
      "result": result,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 5, right: 5),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E4AFF), Color(0xFF1531A8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200.0,
                    child: Text(
                      "Currency Converter",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Input Field with Base Currency Symbol
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                inputValue = value;
                              });
                            },
                            onSubmitted: (value) async {
                              rate = await Client.getRate(from, to);
                              double resultValue = rate * double.parse(value);

                              setState(() {
                                result = resultValue.toStringAsFixed(3);
                              });

                              // Save conversion to Firestore
                              await saveConversion(from, to, double.parse(value), rate, resultValue);
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Input Value to Convert",
                              labelStyle: TextStyle(fontSize: 18.0, color: secondColor),
                              prefixText: "${currency_details[from]} ", // Display currency symbol
                            ),
                            style: TextStyle(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 20.0),

                          // Dropdown Row with Swap Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text("Base Currency", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  customDropDown(currencies, from, (val) {
                                    setState(() {
                                      from = val;
                                    });
                                  }),
                                ],
                              ),

                              Column(
                                children: [
                                  FloatingActionButton(
                                    onPressed: () {
                                      setState(() {
                                        String temp = from;
                                        from = to;
                                        to = temp;
                                      });
                                    },
                                    elevation: 0.0,
                                    backgroundColor: secondColor,
                                    child: Icon(Icons.swap_horiz, color: Colors.white),
                                  ),
                                  SizedBox(height: 5),
                                  Text("Swap Currencies", style: TextStyle(color: Colors.white, fontSize: 14)),
                                ],
                              ),

                              Column(
                                children: [
                                  Text("Target Currency", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  customDropDown(currencies, to, (val) {
                                    setState(() {
                                      to = val;
                                    });
                                  }),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 50.0),

                          // Result Box with Target Currency Symbol
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Result",
                                  style: TextStyle(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${currency_details[to]} $result", // Display currency symbol
                                  style: TextStyle(color: secondColor, fontSize: 36.0, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.0),

                          // View History Button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ConversionHistory()), // Navigate to history screen
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondColor,
                              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              "View History",
                              style: TextStyle(fontSize: 18.0, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
