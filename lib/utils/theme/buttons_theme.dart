import 'package:flutter/material.dart';
import 'package:jewello/utils/theme/color_theme.dart';
import 'package:jewello/utils/theme/text_theme.dart';


class JewelloTxtLink extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const JewelloTxtLink({
    super.key,
    required this.text,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children : [
        TextButton(
          onPressed: onPressed,
          child : Text(
            text,
            style: DDSilverTextStyles.linkText,
          )
        ),
      ]
    );
  }
}


class DDSilverAuthButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double fontSize;
  final double height;
  final bool inv;

  const DDSilverAuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = DDSilverColors.buttonBGColor, // default red
    this.textColor = DDSilverColors.buttonTXTColor,
    this.borderRadius = 50,
    this.fontSize = 20,
    this.height = 55,
    this.inv = false,
  });
  
  @override
  State<DDSilverAuthButton> createState() => _DDSilverAuthButtonState();
}

class _DDSilverAuthButtonState extends State<DDSilverAuthButton> {
  @override
  Widget build(BuildContext context) {
  final Color bg = widget.inv ? widget.textColor : widget.backgroundColor;
  final Color txt = widget.inv ? widget.backgroundColor : widget.textColor;
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: widget.textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            side: widget.inv
              ? BorderSide(color: widget.backgroundColor, width:2)
              : BorderSide.none,
          ),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: txt,
          ),
        ),
      ),
    );
  }
}


