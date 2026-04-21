import 'package:flutter/material.dart';
import 'package:jewello/features/personalization/screens/profile/search.dart';
import 'package:jewello/utils/theme/color_theme.dart';
import 'package:get/get.dart';

class JewelloAuthInput extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const JewelloAuthInput({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
  });

  @override
  State<JewelloAuthInput> createState() => _JewelloAuthInputState();
}

class _JewelloAuthInputState extends State<JewelloAuthInput> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DDSilverColors.border, width: 1),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: DDSilverColors.shadow.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        obscureText: _obscure,

        decoration: InputDecoration(
          hintText: widget.hintText,

          hintStyle: const TextStyle(
            color: DDSilverColors.inputHint,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),

          filled: true,
          fillColor: DDSilverColors.inputFill,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

          prefixIcon: Icon(widget.prefixIcon, color: DDSilverColors.iconGrey),

          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: DDSilverColors.iconGrey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class EditProfileTextField extends StatefulWidget {
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const EditProfileTextField({
    super.key,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
  });

  @override
  State<EditProfileTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<EditProfileTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,

          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(35),
      ),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // hide keyboard just in case
          Get.to(() => const SearchScreen()); // navigate using GetX
        },
        child: AbsorbPointer( // prevents keyboard activation
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Search Product",
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}

// class SearchBar extends StatelessWidget {
//   const SearchBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         // Navigate to Search page
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const SearchScreen()),
//         );
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 10),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade400),
//           borderRadius: BorderRadius.circular(35),
//         ),
//         child: TextField(
//           decoration: InputDecoration(
//             hintText: "Search Product",
//             border: InputBorder.none,
//             icon: Icon(Icons.search, color: Colors.black),
//           ),
//         ),
//       ),
//     );
//   }
// }
