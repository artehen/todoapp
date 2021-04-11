import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SafeArea(child: MyApp()),
        ),
      ),
    ),
  );
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final textEditingController = useTextEditingController();
    return ListView(
      padding: EdgeInsets.all(18.0),
      children: [
        Center(
          child: Text(
            'Todos',
            style: TextStyle(
              fontSize: 54.0,
              fontWeight: FontWeight.w300,
              color: Colors.deepPurpleAccent,
            ),
          ),
        ),
        TextField(
          onSubmitted: (value) {
            textEditingController.clear();
          },
          decoration: InputDecoration(labelText: 'what do you want to do?'),
          controller: textEditingController,
        ),
      ],
    );
  }
}
