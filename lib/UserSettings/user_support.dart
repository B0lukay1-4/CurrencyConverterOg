import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Support & Help'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'FAQs'),
              Tab(text: 'Contact Support'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FAQsTab(),
            ContactSupportTab(),
          ],
        ),
      ),
    );
  }
}

class FAQsTab extends StatelessWidget {
  const FAQsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('faqs')
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final faqs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            final faq = faqs[index];
            return ExpansionTile(
              title: Text(faq['question']),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(faq['answer']),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class ContactSupportTab extends StatefulWidget {
  const ContactSupportTab({super.key});

  @override
  _ContactSupportTabState createState() => _ContactSupportTabState();
}

class _ContactSupportTabState extends State<ContactSupportTab> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _message = '';

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await FirebaseFirestore.instance.collection('support_requests').add({
          'userId': 'anonymous', // Replace with actual user ID if using auth
          'email': _email,
          'message': _message,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'pending',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request submitted successfully!')),
        );
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Your Email'),
              validator: (value) => value!.isEmpty ? 'Email is required' : null,
              onSaved: (value) => _email = value!,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: 'Your Message'),
              maxLines: 4,
              validator: (value) =>
                  value!.isEmpty ? 'Message is required' : null,
              onSaved: (value) => _message = value!,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRequest,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
