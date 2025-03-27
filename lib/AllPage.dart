import 'dart:convert';
import 'package:flutter/material.dart';
import 'currency_conversion_rate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // Hardcoded Map of currency details
final Map<String, Map<String, String>> currencyDetails = {
  "USD": {"name": "United States Dollar", "symbol": "\$"},
  "AED": {"name": "United Arab Emirates Dirham", "symbol": "د.إ"},
  "AFN": {"name": "Afghan Afghani", "symbol": "؋"},
  "ALL": {"name": "Albanian Lek", "symbol": "L"},
  "AMD": {"name": "Armenian Dram", "symbol": "֏"},
  "ANG": {"name": "Netherlands Antillean Guilder", "symbol": "ƒ"},
  "AOA": {"name": "Angolan Kwanza", "symbol": "Kz"},
  "ARS": {"name": "Argentine Peso", "symbol": "\$"},
  "AUD": {"name": "Australian Dollar", "symbol": "A\$"},
  "AWG": {"name": "Aruban Florin", "symbol": "ƒ"},
  "AZN": {"name": "Azerbaijani Manat", "symbol": "₼"},
  "BAM": {"name": "Bosnia-Herzegovina Convertible Mark", "symbol": "KM"},
  "BBD": {"name": "Barbadian Dollar", "symbol": "Bds\$"},
  "BDT": {"name": "Bangladeshi Taka", "symbol": "৳"},
  "BGN": {"name": "Bulgarian Lev", "symbol": "лв"},
  "BHD": {"name": "Bahraini Dinar", "symbol": "ب.د"},
  "BIF": {"name": "Burundian Franc", "symbol": "FBu"},
  "BMD": {"name": "Bermudian Dollar", "symbol": "BD\$"},
  "BND": {"name": "Brunei Dollar", "symbol": "B\$"},
  "BOB": {"name": "Bolivian Boliviano", "symbol": "Bs."},
  "BRL": {"name": "Brazilian Real", "symbol": "R\$"},
  "BSD": {"name": "Bahamian Dollar", "symbol": "B\$"},
  "BTN": {"name": "Bhutanese Ngultrum", "symbol": "Nu."},
  "BWP": {"name": "Botswana Pula", "symbol": "P"},
  "BYN": {"name": "Belarusian Ruble", "symbol": "Br"},
  "BZD": {"name": "Belize Dollar", "symbol": "BZ\$"},
  "CAD": {"name": "Canadian Dollar", "symbol": "C\$"},
  "CDF": {"name": "Congolese Franc", "symbol": "FC"},
  "CHF": {"name": "Swiss Franc", "symbol": "CHF"},
  "CLP": {"name": "Chilean Peso", "symbol": "\$"},
  "CNY": {"name": "Chinese Yuan", "symbol": "¥"},
  "COP": {"name": "Colombian Peso", "symbol": "\$"},
  "CRC": {"name": "Costa Rican Colón", "symbol": "₡"},
  "CUP": {"name": "Cuban Peso", "symbol": "₱"},
  "CVE": {"name": "Cape Verdean Escudo", "symbol": "Esc"},
  "CZK": {"name": "Czech Koruna", "symbol": "Kč"},
  "DJF": {"name": "Djiboutian Franc", "symbol": "Fdj"},
  "DKK": {"name": "Danish Krone", "symbol": "kr"},
  "DOP": {"name": "Dominican Peso", "symbol": "RD\$"},
  "DZD": {"name": "Algerian Dinar", "symbol": "د.ج"},
  "EGP": {"name": "Egyptian Pound", "symbol": "E£"},
  "ERN": {"name": "Eritrean Nakfa", "symbol": "Nfk"},
  "ETB": {"name": "Ethiopian Birr", "symbol": "Br"},
  "EUR": {"name": "Euro", "symbol": "€"},
  "FJD": {"name": "Fijian Dollar", "symbol": "FJ\$"},
  "FKP": {"name": "Falkland Islands Pound", "symbol": "£"},
  "FOK": {"name": "Faroese Króna", "symbol": "kr"},
  "GBP": {"name": "British Pound", "symbol": "£"},
  "GEL": {"name": "Georgian Lari", "symbol": "₾"},
  "GGP": {"name": "Guernsey Pound", "symbol": "£"},
  "GHS": {"name": "Ghanaian Cedi", "symbol": "₵"},
  "GIP": {"name": "Gibraltar Pound", "symbol": "£"},
  "GMD": {"name": "Gambian Dalasi", "symbol": "D"},
  "GNF": {"name": "Guinean Franc", "symbol": "FG"},
  "GTQ": {"name": "Guatemalan Quetzal", "symbol": "Q"},
  "GYD": {"name": "Guyanese Dollar", "symbol": "GY\$"},
  "HKD": {"name": "Hong Kong Dollar", "symbol": "HK\$"},
  "HNL": {"name": "Honduran Lempira", "symbol": "L"},
  "HRK": {"name": "Croatian Kuna", "symbol": "kn"},
  "HTG": {"name": "Haitian Gourde", "symbol": "G"},
  "HUF": {"name": "Hungarian Forint", "symbol": "Ft"},
  "IDR": {"name": "Indonesian Rupiah", "symbol": "Rp"},
  "ILS": {"name": "Israeli New Shekel", "symbol": "₪"},
  "IMP": {"name": "Isle of Man Pound", "symbol": "£"},
  "INR": {"name": "Indian Rupee", "symbol": "₹"},
  "IQD": {"name": "Iraqi Dinar", "symbol": "ع.د"},
  "IRR": {"name": "Iranian Rial", "symbol": "﷼"},
  "ISK": {"name": "Icelandic Króna", "symbol": "kr"},
  "JEP": {"name": "Jersey Pound", "symbol": "£"},
  "JMD": {"name": "Jamaican Dollar", "symbol": "J\$"},
  "JOD": {"name": "Jordanian Dinar", "symbol": "د.ا"},
  "JPY": {"name": "Japanese Yen", "symbol": "¥"},
  "KES": {"name": "Kenyan Shilling", "symbol": "KSh"},
  "KGS": {"name": "Kyrgyzstani Som", "symbol": "с"},
  "KHR": {"name": "Cambodian Riel", "symbol": "៛"},
  "KID": {"name": "Kiribati Dollar", "symbol": "\$"},
  "KMF": {"name": "Comorian Franc", "symbol": "CF"},
  "KRW": {"name": "South Korean Won", "symbol": "₩"},
  "KWD": {"name": "Kuwaiti Dinar", "symbol": "د.ك"},
  "KYD": {"name": "Cayman Islands Dollar", "symbol": "KY\$"},
  "KZT": {"name": "Kazakhstani Tenge", "symbol": "₸"},
  "LAK": {"name": "Lao Kip", "symbol": "₭"},
  "LBP": {"name": "Lebanese Pound", "symbol": "ل.ل"},
  "LKR": {"name": "Sri Lankan Rupee", "symbol": "Rs"},
  "LRD": {"name": "Liberian Dollar", "symbol": "L\$"},
  "LSL": {"name": "Lesotho Loti", "symbol": "L"},
  "LYD": {"name": "Libyan Dinar", "symbol": "ل.د"},
  "MAD": {"name": "Moroccan Dirham", "symbol": "د.م"},
   "MDL": {"name": "Moldovan Leu", "symbol": "L"},
  "MGA": {"name": "Malagasy Ariary", "symbol": "Ar"},
  "MKD": {"name": "Macedonian Denar", "symbol": "ден"},
  "MMK": {"name": "Myanmar Kyat", "symbol": "Ks"},
  "MNT": {"name": "Mongolian Tögrög", "symbol": "₮"},
  "MOP": {"name": "Macanese Pataca", "symbol": "MOP\$"},
  "MRU": {"name": "Mauritanian Ouguiya", "symbol": "UM"},
  "MUR": {"name": "Mauritian Rupee", "symbol": "₨"},
  "MVR": {"name": "Maldivian Rufiyaa", "symbol": "Rf"},
  "MWK": {"name": "Malawian Kwacha", "symbol": "MK"},
  "MXN": {"name": "Mexican Peso", "symbol": "\$"},
  "MYR": {"name": "Malaysian Ringgit", "symbol": "RM"},
  "MZN": {"name": "Mozambican Metical", "symbol": "MT"},
  "NAD": {"name": "Namibian Dollar", "symbol": "N\$"},
  "NGN": {"name": "Nigerian Naira", "symbol": "₦"},
  "NIO": {"name": "Nicaraguan Córdoba", "symbol": "C\$"},
  "NOK": {"name": "Norwegian Krone", "symbol": "kr"},
  "NPR": {"name": "Nepalese Rupee", "symbol": "₨"},
  "NZD": {"name": "New Zealand Dollar", "symbol": "NZ\$"},
  "OMR": {"name": "Omani Rial", "symbol": "﷼"},
  "PAB": {"name": "Panamanian Balboa", "symbol": "B/."},
  "PEN": {"name": "Peruvian Sol", "symbol": "S/."},
  "PGK": {"name": "Papua New Guinean Kina", "symbol": "K"},
  "PHP": {"name": "Philippine Peso", "symbol": "₱"},
  "PKR": {"name": "Pakistani Rupee", "symbol": "₨"},
  "PLN": {"name": "Polish Złoty", "symbol": "zł"},
  "PYG": {"name": "Paraguayan Guaraní", "symbol": "₲"},
  "QAR": {"name": "Qatari Riyal", "symbol": "﷼"},
  "RON": {"name": "Romanian Leu", "symbol": "lei"},
  "RSD": {"name": "Serbian Dinar", "symbol": "РСД"},
  "RUB": {"name": "Russian Ruble", "symbol": "₽"},
  "RWF": {"name": "Rwandan Franc", "symbol": "FRw"},
  "SAR": {"name": "Saudi Riyal", "symbol": "﷼"},
  "SBD": {"name": "Solomon Islands Dollar", "symbol": "SI\$"},
  "SCR": {"name": "Seychellois Rupee", "symbol": "₨"},
  "SDG": {"name": "Sudanese Pound", "symbol": "SDG"},
  "SEK": {"name": "Swedish Krona", "symbol": "kr"},
  "SGD": {"name": "Singapore Dollar", "symbol": "S\$"},
  "SHP": {"name": "Saint Helena Pound", "symbol": "£"},
  "SLE": {"name": "Sierra Leonean Leone", "symbol": "Le"},
  "SLL": {"name": "Sierra Leonean Leone (Old)", "symbol": "Le"},
  "SOS": {"name": "Somali Shilling", "symbol": "Sh"},
  "SRD": {"name": "Surinamese Dollar", "symbol": "\$"},
  "SSP": {"name": "South Sudanese Pound", "symbol": "£"},
  "STN": {"name": "São Tomé and Príncipe Dobra", "symbol": "Db"},
  "SYP": {"name": "Syrian Pound", "symbol": "£"},
  "SZL": {"name": "Swazi Lilangeni", "symbol": "E"},
  "THB": {"name": "Thai Baht", "symbol": "฿"},
  "TJS": {"name": "Tajikistani Somoni", "symbol": "SM"},
  "TMT": {"name": "Turkmenistani Manat", "symbol": "T"},
  "TND": {"name": "Tunisian Dinar", "symbol": "د.ت"},
  "TOP": {"name": "Tongan Paʻanga", "symbol": "T\$"},
  "TRY": {"name": "Turkish Lira", "symbol": "₺"},
  "TTD": {"name": "Trinidad and Tobago Dollar", "symbol": "TT\$"},
  "TVD": {"name": "Tuvaluan Dollar", "symbol": "TVD"},
  "TWD": {"name": "New Taiwan Dollar", "symbol": "NT\$"},
  "TZS": {"name": "Tanzanian Shilling", "symbol": "TSh"},
  "UAH": {"name": "Ukrainian Hryvnia", "symbol": "₴"},
  "UGX": {"name": "Ugandan Shilling", "symbol": "UGX"},
  "UYU": {"name": "Uruguayan Peso", "symbol": "\$U"},
  "UZS": {"name": "Uzbekistani Soʻm", "symbol": "UZS"},
  "VES": {"name": "Venezuelan Bolívar", "symbol": "Bs"},
  "VND": {"name": "Vietnamese Đồng", "symbol": "₫"},
  "VUV": {"name": "Vanuatu Vatu", "symbol": "VT"},
  "WST": {"name": "Samoan Tala", "symbol": "WS\$"},
  "XAF": {"name": "Central African CFA Franc", "symbol": "FCFA"},
  "XCD": {"name": "East Caribbean Dollar", "symbol": "EC\$"},
  "XCG": {"name": "Central Gold Franc", "symbol": "XCG"},
  "XDR": {"name": "IMF Special Drawing Rights", "symbol": "SDR"},
  "XOF": {"name": "West African CFA Franc", "symbol": "CFA"},
  "XPF": {"name": "CFP Franc", "symbol": "₣"},
  "YER": {"name": "Yemeni Rial", "symbol": "﷼"},
  "ZAR": {"name": "South African Rand", "symbol": "R"},
  "ZMW": {"name": "Zambian Kwacha", "symbol": "ZK"},
  "ZWL": {"name": "Zimbabwean Dollar", "symbol": "Z\$"},
};




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
          : currencies.where((currency) => currency.abbreviation.toLowerCase().contains(query)).toList();
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

                              // Fetch name & symbol from map
                           String name = currencyDetails[abbreviation]?["name"] ?? abbreviation;

                              String symbol = currencyDetails[abbreviation]?["symbol"] ?? "";
return Card(
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  color: const Color.fromARGB(255, 255, 255, 255),
  elevation: 3,
  child: ListTile(
    contentPadding: const EdgeInsets.all(16.0),
    title: Text(
      name.isNotEmpty ? name : abbreviation,  // Show abbreviation if name is empty
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
          abbreviation,  // Always show abbreviation
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
