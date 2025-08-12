import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tela de Dashboards')),
      body: Center(
        child: Text(
          'Conteúdo da tela de Dashboards',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
