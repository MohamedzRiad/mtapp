import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:myapp/calculator_provider.dart';
import 'package:myapp/widgets/calculator_button.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CalculatorProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatelessWidget {
  const CalculatorHome({super.key});

  @override
  Widget build(BuildContext context) {
    final calculatorProvider = Provider.of<CalculatorProvider>(context);

    final List<String> simpleButtons = [
      'C', '()', '%', '/',
      '7', '8', '9', '*',
      '4', '5', '6', '-',
      '1', '2', '3', '+',
      '0', '.', '=',
    ];

    final List<String> scientificButtons = [
      'sin', 'cos', 'tan', 'sqrt',
      'ln', 'log', '!', '^',
      'π', 'e', 'C', '()', 
      '%', '/', '7', '8',
      '9', '*', '4', '5', 
      '6', '-', '1', '2',
      '3', '+', '0', '.', '=',
    ];

    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      calculatorProvider.expression,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      calculatorProvider.result,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: GlassContainer(
                height: double.infinity,
                width: double.infinity,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                blur: 10,
                color: Colors.white.withAlpha(26),
                borderColor: Colors.white.withOpacity(0.2),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              calculatorProvider.isScientific
                                  ? Icons.arrow_forward_ios
                                  : Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              calculatorProvider.toggleScientific();
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: calculatorProvider.isScientific
                            ? buildButtonGrid(scientificButtons, calculatorProvider, true)
                            : buildButtonGrid(simpleButtons, calculatorProvider, false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButtonGrid(
      List<String> buttons, CalculatorProvider calculatorProvider, bool isScientific) {
    final crossAxisCount = isScientific ? 5 : 4;
    final fontSize = isScientific ? 18.0 : 24.0;
    final childAspectRatio = isScientific ? 1.2 : 1.1;

    return GridView.builder(
      key: ValueKey(isScientific),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        final buttonText = buttons[index];
        return CalculatorButton(
          text: buttonText,
          fontSize: fontSize,
          onPressed: () {
            calculatorProvider.buttonPressed(buttonText);
          },
        );
      },
    );
  }
}
