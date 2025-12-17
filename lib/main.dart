import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glassmorphic Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CalculatorHomePage(),
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  _CalculatorHomePageState createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage>
    with SingleTickerProviderStateMixin {
  String _expression = '';
  String _result = '';
  bool _isScientific = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _expression = '';
        _result = '';
      } else if (buttonText == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (buttonText == '=') {
        try {
          // Replace user-friendly symbols with parsable ones
          String finalExpression = _expression
              .replaceAll('×', '*')
              .replaceAll('÷', '/')
              .replaceAll('√', 'sqrt');

          Parser p = Parser();
          Expression exp = p.parse(finalExpression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);

          // If the result is an integer, don't show decimal point
          if (eval == eval.truncate()) {
            _result = eval.truncate().toString();
          } else {
            _result = eval.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '');
          }
        } catch (e) {
          _result = 'Error';
        }
      } else if (buttonText == '()') {
        // A simple logic for parenthesis
        if (_expression.endsWith('(') || _expression.endsWith(' ')) {
          _expression += '(';
        } else if (RegExp(r'[0-9)]+$').hasMatch(_expression)) {
          _expression += ')';
        } else {
          _expression += '(';
        }
      } else if (buttonText == ' ') {
        _expression += ' ';
      } else {
        // Handle specific function replacements
        if (['sin', 'cos', 'tan', 'log', 'ln'].contains(buttonText)) {
          _expression += '$buttonText(';
        } else {
          _expression += buttonText;
        }
      }
    });
  }

  void _toggleScientific() {
    setState(() {
      _isScientific = !_isScientific;
      if (_isScientific) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1D),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [_buildDisplay(), _buildKeyboard(constraints)],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _expression,
                maxLines: 2,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 40,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _result,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 64,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard(BoxConstraints constraints) {
    final List<String> basicButtons = [
      'C',
      '()',
      '%',
      '÷',
      '7',
      '8',
      '9',
      '×',
      '4',
      '5',
      '6',
      '-',
      '1',
      '2',
      '3',
      '+',
      '⌫',
      '0',
      '.',
      '=',
    ];

    final List<String> scientificButtons = [
      'sin',
      'cos',
      'tan',
      'log',
      '√',
      '^',
      '(',
      ')',
      'π',
      'e',
      'ln',
      ' ',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF292D36),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: GestureDetector(
              onTap: _toggleScientific,
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _animationController,
                color: Colors.white70,
                size: 30,
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            child: SizeTransition(
              sizeFactor: _animation,
              axis: Axis.vertical,
              child: _buildButtonGrid(scientificButtons, 4, constraints),
            ),
          ),
          _buildButtonGrid(basicButtons, 4, constraints),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildButtonGrid(
    List<String> buttons,
    int crossAxisCount,
    BoxConstraints constraints,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: buttons.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8, // Adjust for a wider button look
      ),
      itemBuilder: (context, index) {
        final buttonText = buttons[index];
        if (buttonText == ' ') {
          return const SizedBox.shrink(); // Empty space for layout
        }

        return CalculatorButton(
          text: buttonText,
          onPressed: () => _onButtonPressed(buttonText),
          backgroundColor: _getButtonBackgroundColor(buttonText),
          foregroundColor: _getButtonForegroundColor(buttonText),
        );
      },
    );
  }

  Color _getButtonBackgroundColor(String buttonText) {
    if (['÷', '×', '-', '+', '='].contains(buttonText)) {
      return const Color(0xFFF06292); // A vibrant pink for operators
    }
    if ([
      'C',
      '()',
      '%',
      '⌫',
      ...['sin', 'cos', 'tan', 'log', 'ln', '√', '^', '(', ')', 'π', 'e'],
    ].contains(buttonText)) {
      return const Color(0xFF373E4B);
    }
    return const Color(0xFF2D323C); // Darker shade for numbers
  }

  Color _getButtonForegroundColor(String buttonText) {
    if (['÷', '×', '-', '+', '='].contains(buttonText)) {
      return Colors.white;
    }
    if (['C', '()', '%'].contains(buttonText)) {
      return const Color(0xFF82F7FF); // Cyan accent
    }
    return Colors.white;
  }
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF2D323C),
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor.withOpacity(0.9),
            backgroundColor.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(-2, -2),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 22,
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
