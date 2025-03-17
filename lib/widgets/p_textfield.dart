import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class PTextField extends StatefulWidget {
  final String? hintText,errorText,obscuringCharacter;
  final String? initialText;
  final bool isObscured;
  final double borderRadius;
  final TextEditingController? controller;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool? enabled;
  final bool? isDense;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? textInputType;
  final InputBorder? focuseInputBorder;
  final InputBorder? enabledInputBorder;
  final EdgeInsetsGeometry? contentPadding;
  final GlobalKey<FormState>? formKey;
  final void Function(String? value) feedback;
  final String? Function(String? value)? validator;
  final Widget? prefixIcon;

  const PTextField({
    Key? key, required this.hintText,this.inputFormatters,this.textInputType=TextInputType.text,this.focuseInputBorder,this.contentPadding ,this.enabledInputBorder,
    required this.feedback, this.isObscured = false,
    this.errorText,  this.controller ,this.enabled=true,this.obscuringCharacter='*',this.fontWeight=FontWeight.w400,this.isDense=false, this.validator, this.formKey, this.borderRadius = 12,
    this.maxLines, this.initialText, this.prefixIcon
  }) : super(key: key);

  @override
  State<PTextField> createState() => _PTextFieldState();
}

class _PTextFieldState extends State<PTextField> {
  TextEditingController? controller;
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    controller ??= TextEditingController()..text = widget.initialText ?? '';
    super.initState();
  }
  late  bool isObscured = widget.isObscured;
  @override
  Widget build(BuildContext context) {
    return  Form(
      key: widget.formKey,
      child: TextFormField(
          enabled: widget.enabled,

          scrollController: scrollController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.controller ?? controller ,
          obscureText: isObscured,
          keyboardType:widget.textInputType??TextInputType.text,
          inputFormatters:widget.inputFormatters??[],
          obscuringCharacter: widget.obscuringCharacter ?? '*',
          style:  TextStyle(fontWeight: widget.fontWeight ?? FontWeight.w400,fontSize: 16,color:  Colors.black),
          maxLines: !isObscured ? widget.maxLines : 1,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            widget.feedback(value);
          },
          validator: (value){
            return null;


          },
          decoration: InputDecoration(
            fillColor: Colors.white,
            isDense: widget.isDense ?? false,
            contentPadding:widget.contentPadding ?? const EdgeInsets.all(20),
            suffixIcon: widget.isObscured ? IconButton(icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility ,color: Colors.grey,),onPressed: (){setState(() {
              isObscured = !isObscured;
            });}) : null,
            prefixIcon: widget.prefixIcon,
            filled: true,
            focusedBorder:widget.focuseInputBorder ?? OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              borderRadius:  BorderRadius.all(Radius.circular(widget.borderRadius)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide:  BorderSide(color:  Theme.of(context).colorScheme.error),
              borderRadius:  BorderRadius.all(Radius.circular(widget.borderRadius)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide:  BorderSide(color:  Theme.of(context).colorScheme.errorContainer),
              borderRadius:  BorderRadius.all(Radius.circular(widget.borderRadius)),
            ),
            enabledBorder:widget.enabledInputBorder ?? OutlineInputBorder(
              borderSide:  BorderSide(color:  Theme.of(context).colorScheme.outline),
              borderRadius:  BorderRadius.all(Radius.circular(widget.borderRadius)),
            ),
            disabledBorder : const OutlineInputBorder(borderSide: BorderSide(color: Colors.white,width: 2.0),),
            hintText:widget.hintText,

          )),
    );
  }
}