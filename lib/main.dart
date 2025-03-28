import 'package:currency_converter/widgets/drop_down.dart';
import 'package:flutter/material.dart';
import 'package:currency_converter/services/api_client.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiClient Client = ApiClient();
  Color mainColor = Color(0xFF212936);
  Color secondColor = Color(0xFF2849E5);
  List<String> currencies = [];

  String from = "USD";
  String to = "EUR";
  double rate = 1.0;
  String result = "";
  String inputValue = "1"; // Default input value

  // Currency symbol map
  final Map<String, String> currencySymbols = {
    'AED': 'د.إ', 'AFN': '؋', 'ALL': 'L', 'AMD': '֏', 'ANG': 'ƒ', 'AOA': 'Kz',
    'ARS': '\$', 'AUD': '\$', 'AWG': 'ƒ', 'AZN': '₼', 'BAM': 'KM', 'BBD': '\$',
    'BDT': '৳', 'BGN': 'лв', 'BHD': '.د.ب', 'BIF': 'FBu', 'BMD': '\$', 'BND': '\$',
    'BOB': 'Bs.', 'BRL': 'R\$', 'BSD': '\$', 'BTN': 'Nu.', 'BWP': 'P', 'BYN': 'Br',
    'BZD': 'BZ\$', 'CAD': '\$', 'CDF': 'FC', 'CHF': 'CHF', 'CLP': '\$', 'CNY': '¥',
    'COP': '\$', 'CRC': '₡', 'CUP': '\$', 'CVE': 'Esc', 'CZK': 'Kč', 'DJF': 'Fdj',
    'DKK': 'kr', 'DOP': 'RD\$', 'DZD': 'د.ج', 'EGP': '£', 'ERN': 'Nfk', 'ETB': 'Br',
    'EUR': '€', 'FJD': '\$', 'FKP': '£', 'FOK': 'kr', 'GBP': '£', 'GEL': '₾',
    'GGP': '£', 'GHS': '₵', 'GIP': '£', 'GMD': 'D', 'GNF': 'FG', 'GTQ': 'Q',
    'GYD': '\$', 'HKD': '\$', 'HNL': 'L', 'HRK': 'kn', 'HTG': 'G', 'HUF': 'Ft',
    'IDR': 'Rp', 'ILS': '₪', 'IMP': '£', 'INR': '₹', 'IQD': 'ع.د', 'IRR': '﷼',
    'ISK': 'kr', 'JEP': '£', 'JMD': '\$', 'JOD': 'د.ا', 'JPY': '¥', 'KES': 'KSh',
    'KGS': 'с', 'KHR': '៛', 'KID': '\$', 'KMF': 'CF', 'KRW': '₩', 'KWD': 'د.ك',
    'KYD': '\$', 'KZT': '₸', 'LAK': '₭', 'LBP': 'ل.ل', 'LKR': 'Rs', 'LRD': '\$',
    'LSL': 'L', 'LYD': 'ل.د', 'MAD': 'د.م.', 'MDL': 'L', 'MGA': 'Ar', 'MKD': 'ден',
    'MMK': 'K', 'MNT': '₮', 'MOP': 'P', 'MRU': 'UM', 'MUR': '₨', 'MVR': 'Rf',
    'MWK': 'MK', 'MXN': '\$', 'MYR': 'RM', 'MZN': 'MT', 'NAD': '\$', 'NGN': '₦',
    'NIO': 'C\$', 'NOK': 'kr', 'NPR': 'Rs', 'NZD': '\$', 'OMR': 'ر.ع.', 'PAB': 'B/.',
    'PEN': 'S/', 'PGK': 'K', 'PHP': '₱', 'PKR': '₨', 'PLN': 'zł', 'PYG': '₲',
    'QAR': 'ر.ق', 'RON': 'lei', 'RSD': 'дин.', 'RUB': '₽', 'RWF': 'FRw', 'SAR': '﷼',
    'SBD': '\$', 'SCR': '₨', 'SDG': 'ج.س.', 'SEK': 'kr', 'SGD': '\$', 'SHP': '£',
    'SLL': 'Le', 'SOS': 'Sh', 'SRD': '\$', 'SSP': '£', 'STN': 'Db', 'SYP': '£',
    'SZL': 'L', 'THB': '฿', 'TJS': 'ЅМ', 'TMT': 'T', 'TND': 'د.ت', 'TOP': 'T\$',
    'TRY': '₺', 'TTD': 'TT\$', 'TVD': '\$', 'TWD': 'NT\$', 'TZS': 'TSh', 'UAH': '₴',
    'UGX': 'USh', 'USD': '\$', 'UYU': '\$', 'UZS': 'so’m', 'VES': 'Bs.', 'VND': '₫',
    'VUV': 'VT', 'WST': 'T', 'XAF': 'FCFA', 'XCD': '\$', 'XOF': 'CFA', 'XPF': '₣',
    'YER': '﷼', 'ZAR': 'R', 'ZMW': 'ZK', 'ZWL': '\$'
  };

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: SafeArea(
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
                          setState(() {
                            result = (rate * double.parse(value)).toStringAsFixed(3);
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Input Value to Convert",
                          labelStyle: TextStyle(
                            fontSize: 18.0,
                            color: secondColor,
                          ),
                          prefixText: "${currencySymbols[from]} ", // Display currency symbol
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20.0),

                      // Dropdown Row with Swap Button and Label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Base Currency",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              customDropDown(currencies, from, (val) {
                                setState(() {
                                  from = val;
                                });
                              }),
                            ],
                          ),

                          // Swap Button with Label
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
                              Text(
                                "Swap Currencies",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),

                          Column(
                            children: [
                              Text(
                                "Target Currency",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${currencySymbols[to]} $result", // Display currency symbol
                              style: TextStyle(
                                color: secondColor,
                                fontSize: 36.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
