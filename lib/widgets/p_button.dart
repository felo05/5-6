import 'package:flutter/material.dart';
import 'dart:core';
import '../constants.dart';
import 'p_text.dart';




class PButton extends StatefulWidget {
  final GestureTapCallback? onPressed;
  final String? title;
  final PSize size;
  final PStyle style;
  final List<String>? dropDown;
  final IconData? icon;
  final bool isFitWidth;


  const PButton({Key? key, required this.onPressed,this.size = PSize.medium,this.isFitWidth=false,this.title, this.style = PStyle.secondary, this.icon, this.dropDown}) : super(key: key);

  @override
  State<PButton> createState() => _PButtonState();
}

class _PButtonState extends State<PButton> {
  bool singleTap = false;

  @override
  Widget build(BuildContext context) {
    return   ElevatedButton(onPressed: widget.onPressed != null ? ()  {
      if (!singleTap) {
        Function.apply(widget.onPressed!, []);
        singleTap = true;
        Future.delayed(const Duration(seconds: 3)).then((value) => singleTap = false);
      }
    } : null,onHover:(m){},

        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26),
            side:widget.style == PStyle.tertiary ? const BorderSide(width: 1.0) : BorderSide.none),
            elevation: 0,
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
            minimumSize:widget.isFitWidth?const Size.fromHeight(40): const Size(80, 40)
        ), child:  Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.icon != null ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(widget.icon,size: 20,),
            ) : const SizedBox.shrink(),
            widget.title != null ? Flexible(
              fit: FlexFit.loose,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: PText(title: widget.title!, size: widget.size),
              ),
            ): const SizedBox.shrink(),

          ],
        ));
  }
}

