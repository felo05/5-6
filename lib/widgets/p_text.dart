import 'package:flutter/material.dart';
import '../constants.dart';


class PText extends StatelessWidget {
  final String title;
  final PSize size;
  final TextDecoration? decoration;
  final FontWeight fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? alignText;
  final Color? fontColor;
  const PText({Key? key, required this.title, required this.size,
    this.fontWeight = FontWeight.w600, this.overflow,this.maxLines,this.decoration=TextDecoration.none, this.alignText,  this.fontColor,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fontSize = 10;
    if(size == PSize.large){
      fontSize = 18;
    } else if(size == PSize.small){
      fontSize = 12;
    } else if(size == PSize.veryLarge){
      fontSize = 20;
    } else if(size == PSize.medium){
      fontSize = 14;
    }else if(size == PSize.title){
      fontSize = 30;
    }else if(size == PSize.semiLarge){
      fontSize = 16;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(title,textAlign: alignText ?? TextAlign.start,style: TextStyle(fontWeight: fontWeight,
            fontSize: fontSize,
            height: 1.2,
            letterSpacing: -0.02,
            decoration: decoration,
            color: fontColor,
            overflow: overflow),maxLines:maxLines,)),
      ],
    );
  }

}

