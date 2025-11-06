import 'package:acta/acta.dart';
import 'package:flutter/material.dart';

class CustomReport extends Reporter {
  CustomReport() {
    print('CustomReport constructor');
    print(WidgetsBinding.instance); // Custom Reporter needs to be LAZY
  }
  @override
  Future<void> report(Event report) async {
    print('Hello From custom Reporter!');
  }
}
