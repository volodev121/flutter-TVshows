import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/common/styles.dart';

class EmailField extends StatelessWidget {
  EmailField(this._emailController);
  final _emailController;

// Email textFormField
  Widget emailTextField() {
    return TextFormField(
      maxLines: 1,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      cursorColor: primaryBlue,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: translate("Enter_your_email"),
        hintStyle: TextStyle(
          color: Color.fromRGBO(34, 34, 34, 0.4),
          fontSize: 18,
        ),
      ),
      style: TextStyle(
        color: Color.fromRGBO(34, 34, 34, 0.7),
        fontSize: 18,
      ),
      validator: (val) {
        if (val!.length == 0) {
          return translate('Email_cannot_be_empty');
        } else {
          if (!val.contains('@')) {
            return translate('Invalid_Email');
          } else {
            return null;
          }
        }
      },
      onSaved: (val) => _emailController.text = val,
    );
  }

  Widget emailTextFieldContainer() {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.9),
          offset: Offset(0, 2.0),
          blurRadius: 4.0,
        )
      ]),
      child: Padding(
        padding:
            EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0, bottom: 10.0),
        child: emailTextField(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: emailTextFieldContainer(),
    );
  }
}
