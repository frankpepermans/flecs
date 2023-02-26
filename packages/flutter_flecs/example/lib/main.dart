import 'package:example/systems/init_system.dart';
import 'package:example/systems/update_system.dart';
import 'package:example/tasks_view.dart';
import 'package:flecs/flecs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flecs/flutter_flecs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flecs demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Flecs(
            startupSystems: [initSystem],
            systems: [updateSystem],
            resources: const ['hi from Flecs!'],
            child: const Column(
              children: [
                Expanded(child: TasksView()),
                Expanded(child: TasksView()),
              ],
            ),
          ),
        ),
      );
}
