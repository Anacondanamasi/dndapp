import 'package:flutter/material.dart';
import 'package:jewello/utils/theme/text_theme.dart';

class CustomDropdownTheme extends StatefulWidget {
  final String label;                    // Title shown above the box
  final List<String> options;            // Items to display
  final String initialValue;             // Starting value
  final ValueChanged<String> onChanged;  // Callback when user picks
  final needLabel;
  const CustomDropdownTheme({
    super.key,
    required this.label,
    required this.options,
    required this.initialValue,
    required this.onChanged, this.needLabel=true, 
  });

  @override
  State<CustomDropdownTheme> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdownTheme> {
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.needLabel)
            Text(
              widget.label,
              style: DDSilverTextStyles.labelText
            ),
            
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selected,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                style: const TextStyle(fontSize: 16, color: Colors.black),
                items: widget.options
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selected = value);
                    widget.onChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
