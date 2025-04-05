import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  final String apiKey = "85ed46a832246b61a3969de4";

  Future<List<String>> getCurrencies() async {
    final Uri currencyURL = Uri.parse(
        "https://v6.exchangerate-api.com/v6/$apiKey/latest/USD");

    http.Response res = await http.get(currencyURL);
    
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      var conversionRates = body["conversion_rates"];

      if (conversionRates == null) {
        throw Exception("Invalid API response");
      }

      List<String> currencies = conversionRates.keys.toList();
  
      return currencies;
    } else {
      throw Exception("Failed to connect to API");
    }
  }

  Future<double> getRate(String from, String to) async {
    final Uri rateURL = Uri.parse(
        "https://v6.exchangerate-api.com/v6/$apiKey/pair/$from/$to"
        
        );

    http.Response res = await http.get(rateURL);
    
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      double rate = body["conversion_rate"];
      return rate;
    } else {
      throw Exception("Failed to fetch exchange rate");
    }
  }
}
