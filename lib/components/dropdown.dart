import 'package:flutter/material.dart';

class CustomDropdownButtonFormField<T> extends StatefulWidget {
  const CustomDropdownButtonFormField({
    super.key,
    required this.items,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.value,
    this.hint,
    this.labelText,
    this.isExpanded = false,
    this.enabled = true,
    this.errorText, // Added errorText
    this.prefixIcon,
    this.suffixIcon,
    this.initialSelection,
  });

  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldSetter<T?>? onSaved;
  final FormFieldValidator<T?>? validator;
  final T? value;
  final Widget? hint;
  final String? labelText;
  final bool isExpanded;
  final bool enabled;
  final String? errorText; // Added errorText
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final T? initialSelection;

  @override
  State<CustomDropdownButtonFormField<T>> createState() => _CustomDropdownButtonFormFieldState<T>();
}

class _CustomDropdownButtonFormFieldState<T> extends State<CustomDropdownButtonFormField<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value ?? widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: widget.value,
      onSaved: widget.onSaved,
      validator: widget.validator,
      builder: (FormFieldState<T> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hint,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                border: const OutlineInputBorder(),
                enabled: widget.enabled,
                errorText: widget.errorText ?? state.errorText, // Use provided errorText or state.errorText
                errorMaxLines: 3,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: _selectedValue,
                  isExpanded: widget.isExpanded,
                  onChanged: widget.enabled
                      ? (T? newValue) {
                          setState(() {
                            _selectedValue = newValue;
                          });
                          state.didChange(newValue);
                          if (widget.onChanged != null) {
                            widget.onChanged!(newValue);
                          }
                        }
                      : null,
                  items: widget.items,
                  hint: widget.hint,
                  disabledHint: widget.hint,
                ),
              ),
            ),
            //Removed the Text widget that showed the error.
          ],
        );
      },
    );
  }
}
