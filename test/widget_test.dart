import 'package:aurastack/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('constructs the application root widget', () {
    const app = MyApp();

    expect(app, isA<StatefulWidget>());
  });
}
