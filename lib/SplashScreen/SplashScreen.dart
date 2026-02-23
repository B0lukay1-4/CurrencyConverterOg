import 'package:currency_converter/CurrencyPages/CurrencyList.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

   @override
  void initState(){
    super.initState();
    Future.delayed(const Duration(seconds: 3), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Currencylist()),
      );
    });
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          children: [
         Padding(
           padding: const EdgeInsets.only(top: 200),
           child: Image.asset("assets/images/currenseelogo.png",width: 400, height:500),
         )
          ],
        ),
      ),
    );
  }
}