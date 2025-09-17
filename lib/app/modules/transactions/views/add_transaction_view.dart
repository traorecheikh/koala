import 'package:flutter/material.dart';

class AddTransactionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une transaction')),
      body: const Center(child: Text('Page d\'ajout de transaction')),
    );
  }
}
