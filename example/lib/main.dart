import 'dart:io';


import 'package:example/pages/test_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'pages/custom_column_nested_table.dart';
import 'pages/custom_column_table.dart';
import 'pages/custom_data_table.dart';
import 'pages/local_table.dart';
import 'pages/simple_table.dart';

void enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {
  enablePlatformOverrideForDesktop();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Json Table Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => RootPage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/customData': (context) => CustomDataTable(),
      },
    );
  }
}

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Table Widget"),
          actions: [
            TextButton(
              child: const Text(
                "TEST LIVE",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/customData');
              },
            )
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                text: "Simple Table",
              ),
              Tab(
                text: "Custom Table",
              ),
              Tab(
                text: "Nested Data Table",
              ),
              Tab(
                text: "Local Data Table",
              ),
              Tab(
                text: "Test Page",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            SimpleTable(),
            CustomColumnTable(),
            CustomColumnNestedTable(),
            LocalTable(),
            const TestPage(),
          ],
        ),
      ),
    );
  }
}
