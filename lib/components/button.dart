import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.foregroundColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.textStyle,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.side,
    this.minimumSize,
    this.maximumSize,
    this.alignment = Alignment.center,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final BorderRadius borderRadius;
  final BorderSide? side;
  final Size? minimumSize;
  final Size? maximumSize;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey; // Default disabled color
            }
            return foregroundColor ?? Theme.of(context).colorScheme.primary; // Use provided or theme primary
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade300; // Default disabled background
            }
            return backgroundColor ?? Colors.transparent; // Default to transparent
          },
        ),
        padding: MaterialStateProperty.all(padding),
        textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
          (Set<MaterialState> states) {
            return textStyle ?? Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500);
          },
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: side ?? BorderSide.none,
          ),
        ),
        minimumSize: MaterialStateProperty.all(minimumSize ?? Size.zero),
        maximumSize: MaterialStateProperty.all(maximumSize ?? Size.infinite),
        // alignment: MaterialStateProperty.all(alignment),
      ),
      child: child,
    );
  }
}

// Example usage in a widget:
class ButtonExample extends StatelessWidget {
  const ButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Text Button Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomTextButton(
              onPressed: () {
                print('Button 1 pressed');
              },
              child: const Text('Simple Button'),
            ),
            const SizedBox(height: 20),
            CustomTextButton(
              onPressed: () {
                print('Button 2 pressed');
              },
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              borderRadius: BorderRadius.circular(12),
              child: const Text('Styled Button'),
            ),
            const SizedBox(height: 20),
            CustomTextButton(
              onPressed: () {
                print('Button 3 pressed');
              },
              side: const BorderSide(color: Colors.green, width: 2.0),
              child: const Text('Outlined Button'),
            ),
            const SizedBox(height: 20),
            CustomTextButton(
              onPressed: null, // Example of a disabled button
              child: const Text('Disabled Button'),
            ),
            const SizedBox(height: 20),
            CustomTextButton(
              onPressed: () {
                print('Button with Icon pressed');
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Add Item'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ButtonExample(),
  ));
}