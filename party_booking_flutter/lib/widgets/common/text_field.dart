import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class TextFieldWidget extends StatelessWidget {
  final String mHindText;
  final String mAttribute;
  final bool mShowObscureText;
  final TextInputType mTextInputType;
  final List<FormFieldValidator> mValidators;
  final bool readOnly;

  TextFieldWidget( // ignore: avoid_init_to_null
      {
    @required this.mHindText,
    @required this.mAttribute,
    this.mShowObscureText = false,
    this.mTextInputType = TextInputType.text,
    this.mValidators,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle mStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
    return FormBuilderTextField(
        attribute: mAttribute,
        obscureText: mShowObscureText,
        readOnly: readOnly,
        maxLines: 1,
        style: mStyle,
        keyboardType: mTextInputType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            labelText: mHindText,
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32))),
        validators: mValidators);
  }
}
