import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class CouponField extends StatelessWidget {
  CouponField(this._nameController);
  final _nameController;

//  Name TextFormField
  Widget nameTextField() {
    return TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.text,
      controller: _nameController,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: translate("Coupon_Code"),
        hintStyle:
            TextStyle(color: Color.fromRGBO(34, 34, 34, 0.4), fontSize: 18),
      ),
      style: TextStyle(color: Color.fromRGBO(34, 34, 34, 0.7), fontSize: 18),
      validator: (val) {
        if (val!.length == 0) {
          return translate('Name_cannot_be_empty');
        } else {
          if (val.length < 5) {
            return translate('Required_at_least_5_characters');
          } else {
            return null;
          }
        }
      },
      onSaved: (val) => _nameController.text = val,
    );
  }

//  Name field container
  Widget nameFieldContainer() {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.9),
          offset: Offset(0, 2.0),
          blurRadius: 1.0,
        )
      ]),
      child: Padding(
        padding: EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          top: 10.0,
          bottom: 10.0,
        ),
        child: nameTextField(),
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
      child: nameFieldContainer(),
    );
  }
}
