import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Main entry point of the app. Initializes ChangeNotifierProvider for app state.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const StateManagementActivity(),
    ),
  );
}

// ThemeModel class manages App State for theme toggling using ChangeNotifier.
class ThemeModel with ChangeNotifier {
  bool _isDark = false;

  // Getter to return the current theme mode state (dark or light).
  bool get isDark => _isDark;

  // Function to toggle between dark mode and light mode, then notify listeners.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

// Root application widget that listens to ThemeModel to apply dark or light theme.
class StateManagementActivity extends StatelessWidget {
  const StateManagementActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      theme: themeModel.isDark ? ThemeData.dark() : ThemeData.light(),
      home: const MyHomePage(),
    );
  }
}

// Screen 1: Counter Page using Ephemeral (local) state via setState.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // Function to increment counter state using setState.
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ephemeral State Example'),
        actions: [
          // Entry point button on upper right corner to go to the Theme toggle page
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Go to Theme Page',
            onPressed: () {
              // Reset the ephemeral counter state when navigating to theme page
              setState(() {
                _counter = 0;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeTogglePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Screen 2: Theme toggle page using App State managed by Provider.
class ThemeTogglePage extends StatelessWidget {
  const ThemeTogglePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App State Example'),
        actions: [
          // Switch to enable/disable dark mode
          Switch(
            value: themeModel.isDark,
            onChanged: (_) => themeModel.toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Toggle the theme using the switch in the app bar.'),
            const SizedBox(height: 20),
            // Button going back to the increment page
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Increment Page'),
            ),
          ],
        ),
      ),
    );
  }
}
