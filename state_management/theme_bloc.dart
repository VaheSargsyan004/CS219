import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    Provider<ThemeBloc>(
      create: (_) => ThemeBloc(),
      dispose: (_, bloc) => bloc.dispose(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ParentWidget(),
    );
  }
}

/// 🧠 BLoC Class

class ThemeBloc {
  bool _isDarkMode = false;
  Color _squareColor = Colors.blue;

  final _modeController = StreamController<bool>.broadcast();
  final _colorController = StreamController<Color>.broadcast();

  Stream<bool> get modeStream => _modeController.stream;
  Stream<Color> get colorStream => _colorController.stream;

  bool get isDarkMode => _isDarkMode;
  Color get squareColor => _squareColor;

  void toggleMode() {
    _isDarkMode = !_isDarkMode;
    _modeController.sink.add(_isDarkMode);
  }

  void changeColor() {
    final random = Random();
    _squareColor = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    _colorController.sink.add(_squareColor);
  }

  void dispose() {
    _modeController.close();
    _colorController.close();
  }
}

/// 🏠 Parent Widget
class ParentWidget extends StatelessWidget {
  const ParentWidget({super.key});

  Widget build(BuildContext context) {
    final bloc = Provider.of<ThemeBloc>(context);

    return StreamBuilder<bool>(
      stream: bloc.modeStream,
      initialData: bloc.isDarkMode,
      builder: (context, modeSnapshot) {
        final isDarkMode = modeSnapshot.data ?? false;

        return Scaffold(
          backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
          appBar: AppBar(
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue,
            title: Text(
              'Parent–Child BLoC Example',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<Color>(
                  stream: bloc.colorStream,
                  initialData: bloc.squareColor,
                  builder: (context, colorSnapshot) {
                    final color = colorSnapshot.data ?? Colors.blue;
                    return Container(
                      width: 200,
                      height: 200,
                      color: color,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  isDarkMode ? 'Dark Mode' : 'Light Mode',
                  style: TextStyle(
                    fontSize: 24,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                const ChildWidget(), // 👶 Child widget below
              ],
            ),
          ),
        );
      },
    );
  }
}


/// 👶 Child Widget
class ChildWidget extends StatelessWidget {
  const ChildWidget({super.key});

  Widget build(BuildContext context) {
    final bloc = Provider.of<ThemeBloc>(context, listen: false);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Dark Mode'),
            StreamBuilder<bool>(
              stream: bloc.modeStream,
              initialData: bloc.isDarkMode,
              builder: (context, snapshot) {
                final isDark = snapshot.data ?? false;
                return Switch(
                  value: isDark,
                  onChanged: (_) => bloc.toggleMode(),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: bloc.changeColor,
          child: const Text('Change Square Color'),
        ),
      ],
    );
  }
}
