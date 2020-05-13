import 'package:Zentors/Providers/AuthService.dart';
import 'package:Zentors/app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => App(),
        },
          debugShowCheckedModeBanner: false,
          title: 'Zentors',
          theme: ThemeData(
            primarySwatch: Colors.grey,
          ),
          ),
    );
  }
}
