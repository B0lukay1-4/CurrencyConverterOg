import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversionHistory extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Conversion History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection("conversionHistory").orderBy("timestamp", descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No history available"));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text("${data['from']} → ${data['to']}"),
                subtitle: Text("Amount: ${data['amount']} | Result: ${data['result']}"),
                trailing: Text(data['timestamp'] != null 
                    ? data['timestamp'].toDate().toString() 
                    : "No Timestamp"),

              );
            }).toList(),
          );
        },
      ),
    );
  }
}
