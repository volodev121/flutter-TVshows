import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/providers/user_profile_provider.dart';
import '/ui/screens/splash_screen.dart';
import '/ui/shared/appbar.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  Dio dio = new Dio();
  FormData formdata = FormData();
  TextEditingController _editNameController = new TextEditingController();
  TextEditingController _editDOBController = new TextEditingController();
  TextEditingController _editMobileController = new TextEditingController();
  DateTime _dateTime = new DateTime.now();
  String pickedDate = '';
  var sEmail;
  var sPass;
  var files;
  String status = '';
  String? base64Image;
  File? tmpFile;
  String errMessage = translate('Error_Uploading_Image');
  var currentPassword, newPassword, newDob, newMobile, newName;
  bool isShowIndicator = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  final picker = ImagePicker();
  String? _retrieveDataError;
//  Show a dialog after updating password
  Future<void> _profileUpdated(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: Center(
            child: Container(
              decoration: BoxDecoration(),
              child: AlertDialog(
                backgroundColor: Colors.white,
                contentPadding: const EdgeInsets.all(5.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0))),
                title: Text(
                  translate('Profile_Saved_'),
                  style: TextStyle(color: Color.fromRGBO(34, 34, 34, 1.0)),
                ),
                content: Container(
                  height: 70.0,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 2.0,
                      ),
                      Icon(FontAwesomeIcons.circleCheck,
                          size: 40.0, color: activeDotColor),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        translate('Your_profile_updated'),
                        style: TextStyle(
                          color: Color.fromRGBO(34, 34, 34, 1.0),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      translate('Ok_'),
                      style: TextStyle(
                        fontSize: 16.0,
                        color: activeDotColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.splashScreen,
                        arguments: SplashScreen(
                          token: authToken,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          onWillPop: () async => false,
        );
      },
    );
  }

//  This future process the profile update and save details to the server.
  Future<String?> updateProfile() async {
    newDob = DateFormat("y-MM-dd").format(_dateTime);
    newMobile = _editMobileController.text;
    newName = _editNameController.text;
    String imagefileName = files != null ? files.path.split('/').last : '';

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(APIData.userProfileUpdate),
      );
      var headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        HttpHeaders.authorizationHeader: "Bearer $authToken",
      };
      if (imagefileName != '' || files != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', files.path));
      }

      request.headers.addAll(headers);

      if (sEmail != null) {
        request.fields['email'] = sEmail;
      }
      if (sPass != null) {
        request.fields['current_password'] = sPass;
        request.fields['new_password'] = sPass;
      }
      if (newDob != null) {
        request.fields['dob'] = newDob;
      }
      if (newMobile != null) {
        request.fields['mobile'] = newMobile;
      }
      if (newName != null) {
        request.fields['name'] = newName;
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        setState(() {
          isShowIndicator = false;
        });
        _profileUpdated(context);
      }
    } catch (e) {
      setState(() {
        isShowIndicator = false;
      });
    }
    return null;
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        files = response.file;
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

//  For selecting image from camera
  chooseImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      files = pickedFile;
    });
  }

//  For selecting image from gallery
  chooseImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      files = pickedFile;
    });
  }

  DateTime selectedDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: new DateTime(1950),
        lastDate: new DateTime.now());
    if (picked != null && picked != newDob)
      setState(() {
        _editDOBController.text = DateFormat.yMMMd().format(picked);
        _dateTime = picked;
      });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
          .userProfileModel!;
      print("DOB: ${userDetails.user!.dob}");
      newName = _editNameController.text;
      newDob = _editDOBController.text;
      newMobile = _editMobileController.text;
      var inputDate;
      if ("${userDetails.user!.dob}" != "null" ||
          userDetails.user!.dob != null) {
        DateTime parseDate =
            new DateFormat("yyyy-MM-dd").parse(userDetails.user!.dob);
        inputDate = DateTime.parse(parseDate.toString());
        inputDate = DateFormat.yMMMd().format(inputDate);
      } else {
        inputDate = '';
      }

      _editNameController.text =
          userDetails.user!.name == null ? '' : "${userDetails.user!.name}";
      _editDOBController.text =
          "${userDetails.user!.dob}" == "null" || userDetails.user!.dob == null
              ? ''
              : inputDate;
      _editMobileController.text = "${userDetails.user!.mobile}" == "null"
          ? ''
          : "${userDetails.user!.mobile}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: customAppBar(context, translate("Edit_Profile"))
          as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }

//  Scaffold body
  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              showImage(),
              browseImageButton(),
            ],
          ),
          form(),
        ],
      ),
    );
  }

//  Browse button container
  Widget browseImageButton() {
    return Container(
      height: 45.0,
      width: 45.0,
      margin: EdgeInsets.fromLTRB(125.0, 170.0, 0.0, 0.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: activeDotColor,
      ),
      child: IconButton(
        icon: Icon(Icons.add_a_photo),
        onPressed: _onButtonPressed,
      ),
    );
  }

//  Form that containing text fields to update profile
  Widget form() {
    return Container(
      padding:
          EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0, bottom: 20.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            buildNameTextField(translate("Name_")),
            SizedBox(
              height: 20.0,
            ),
            buildDOBTextField(translate("Date_of_Birth")),
            SizedBox(
              height: 20.0,
            ),
            buildMobileTextField(translate("Mobile_Number")),
            SizedBox(
              height: 20.0,
            ),
            SizedBox(height: 20.0),
            updateButtonContainer(),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

//  Name TextField to update name
  Widget buildNameTextField(String hintText) {
    return TextFormField(
      controller: _editNameController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(5.0),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: Icon(Icons.account_box),
      ),
      validator: (val) {
        if (val!.length == 0) {
          return translate('Name_cannot_be_empty');
        } else {
          if (val.length < 4) {
            return translate('Name_requires_at_least_5_characters');
          } else {
            return null;
          }
        }
      },
      onSaved: (val) => _editNameController.text = val!,
    );
  }

  Widget buildDOBTextField(String hintText) {
    return TextField(
      controller: _editDOBController,
      focusNode: AlwaysDisabledFocusNode(),
      onTap: () {
        _selectDate(context);
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(5.0),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: Icon(Icons.calendar_today),
      ),
    );
  }

//  TextField to update mobile number
  Widget buildMobileTextField(String hintText) {
    return TextField(
      controller: _editMobileController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(5.0),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: Icon(Icons.phone),
      ),
    );
  }

//  Update button container
  Widget updateButtonContainer() {
    return InkWell(
      child: Container(
        height: 56.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5.0),
          // Box decoration takes a gradient
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            // Add one stop for each color. Stops should increase from 0 to 1
            stops: [0.1, 0.5, 0.7, 0.9],
            colors: [
              // Colors are easy thanks to Flutter's Colors class.
              Color.fromRGBO(72, 163, 198, 0.4).withOpacity(0.4),
              Color.fromRGBO(72, 163, 198, 0.3).withOpacity(0.5),
              Color.fromRGBO(72, 163, 198, 0.2).withOpacity(0.6),
              Color.fromRGBO(72, 163, 198, 0.1).withOpacity(0.7),
            ],
          ),
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 10.0,
              offset: new Offset(1.0, 10.0),
            ),
          ],
        ),
        child: Center(
          child: isShowIndicator == true
              ? CircularProgressIndicator(
                  backgroundColor: Colors.white,
                )
              : Text(
                  translate("Update_Profile"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
        ),
      ),
      onTap: () {
        // To remove keypad on tapping button
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          isShowIndicator = true;
        });
        final form = formKey.currentState!;
        form.save();
        if (form.validate() == true) {
          updateProfile();
        } else {
          setState(() {
            isShowIndicator = false;
          });
        }
      },
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget _previewImage(userDetails) {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (files != null) {
      if (kIsWeb) {
        // Why network?
        // See https://pub.flutter-io.cn/packages/image_picker#getting-ready-for-the-web-platform
        return Image.network(files!.path);
      } else {
        return Container(
          margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          height: 190.0,
          width: 150.0,
          decoration: new BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            border: new Border.all(
                color: Colors.white.withOpacity(0.0), width: 10.0),
            borderRadius: new BorderRadius.only(
              bottomLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0),
            ),
          ),
          child: Card(
            margin: EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.only(
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0),
              ),
            ),
            child: ClipRRect(
              borderRadius: new BorderRadius.only(
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0),
              ),
              child: Semantics(
                  child: Image.file(
                    File(files!.path),
                  ),
                  label: 'image_picker_example_picked_image'),
            ),
          ),
        );
      }
    } else {
      return Container(
        margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        height: 190.0,
        width: 150.0,
        decoration: new BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          border:
              new Border.all(color: Colors.white.withOpacity(0.0), width: 10.0),
          borderRadius: new BorderRadius.only(
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0),
          ),
        ),
        child: Card(
          margin: EdgeInsets.all(0.0),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.only(
              bottomLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0),
            ),
          ),
          child: ClipRRect(
            borderRadius: new BorderRadius.only(
              bottomLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0),
            ),
            child: tmpFile == null
                ? userDetails!.user!.image == null ||
                        "${userDetails.user!.image}" == "null"
                    ? Image.asset(
                        "assets/avatar.png",
                        fit: BoxFit.cover,
                        scale: 1.7,
                      )
                    : Image.network(
                        "${APIData.profileImageUri}" +
                            "${userDetails.user!.image}",
                        fit: BoxFit.cover,
                        scale: 1.7,
                      )
                : Image.file(
                    tmpFile!,
                    fit: BoxFit.cover,
                    scale: 1.7,
                  ),
          ),
        ),
      );
    }
  }

//  Preview of selected image
  Widget showImage() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel;
    return FutureBuilder<void>(
      future: retrieveLostData(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Container(
                margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                height: 190.0,
                width: 150.0,
                decoration: new BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    border: new Border.all(
                        color: Colors.white.withOpacity(0.0), width: 10.0),
                    borderRadius: new BorderRadius.only(
                        bottomLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0))),
                child: Card(
                  margin: EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.only(
                        bottomLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: new BorderRadius.only(
                        bottomLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0)),
                    child: tmpFile == null
                        ? userDetails!.user!.image == null ||
                                "${userDetails.user!.image}" == "null"
                            ? Image.asset(
                                "assets/avatar.png",
                                fit: BoxFit.cover,
                                scale: 1.7,
                              )
                            : Image.network(
                                "${APIData.profileImageUri}" +
                                    "${userDetails.user!.image}",
                                fit: BoxFit.cover,
                                scale: 1.7,
                              )
                        : Image.file(
                            tmpFile!,
                            fit: BoxFit.cover,
                            scale: 1.7,
                          ),
                  ),
                ));
          case ConnectionState.done:
            return _previewImage(userDetails);
          default:
            if (snapshot.hasError) {
              return Text(
                'Pick image/video error: ${snapshot.error}}',
                textAlign: TextAlign.center,
              );
            } else {
              return Container(
                margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                height: 190.0,
                width: 150.0,
                decoration: new BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  border: new Border.all(
                      color: Colors.white.withOpacity(0.0), width: 10.0),
                  borderRadius: new BorderRadius.only(
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0),
                  ),
                ),
                child: Card(
                  margin: EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.only(
                      bottomLeft: Radius.circular(25.0),
                      bottomRight: Radius.circular(25.0),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: new BorderRadius.only(
                      bottomLeft: Radius.circular(25.0),
                      bottomRight: Radius.circular(25.0),
                    ),
                    child: tmpFile == null
                        ? userDetails!.user!.image == null ||
                                "${userDetails.user!.image}" == "null"
                            ? Image.asset(
                                "assets/avatar.png",
                                fit: BoxFit.cover,
                                scale: 1.7,
                              )
                            : Image.network(
                                "${APIData.profileImageUri}" +
                                    "${userDetails.user!.image}",
                                fit: BoxFit.cover,
                                scale: 1.7,
                              )
                        : Image.file(
                            tmpFile!,
                            fit: BoxFit.cover,
                            scale: 1.7,
                          ),
                  ),
                ),
              );
            }
        }
      },
    );
  }

//  Creating bottom sheet for selecting profile picture
  Widget bottomSheet() {
    return Container(
      child: Column(
        children: <Widget>[
          InkWell(
              onTap: () {
                chooseImageFromCamera();
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 0.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.camera,
                      color: Color.fromRGBO(34, 34, 34, 1.0),
                      size: 35,
                    ),
                    Container(
                      width: 250.0,
                      child: ListTile(
                        title: Text(
                          translate('Camera_'),
                          style:
                              TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),
                        ),
                        subtitle: Text(
                          translate("Click_profile_picture_from_camera"),
                          style:
                              TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),
                        ),
                      ),
                    )
                  ],
                ),
              )),
          InkWell(
              onTap: () {
                chooseImageFromGallery();
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 0.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.photo,
                      color: Color.fromRGBO(34, 34, 34, 1.0),
                      size: 35,
                    ),
                    Container(
                      width: 260.0,
                      child: ListTile(
                        title: Text(
                          translate('Gallery_'),
                          style: TextStyle(
                            color: Color.fromRGBO(20, 20, 20, 1.0),
                          ),
                        ),
                        subtitle: Text(
                          translate("Choose_profile_picture_from_gallery"),
                          style: TextStyle(
                            color: Color.fromRGBO(20, 20, 20, 1.0),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10.0),
          topRight: const Radius.circular(10.0),
        ),
      ),
    );
  }

//  Show bottom sheet
  void _onButtonPressed() {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return new Container(
          height: 190.0,
          color: Colors.transparent, //could change this to Color(0xFF737373),
          child: new Container(
            decoration: new BoxDecoration(
              color: Color.fromRGBO(34, 34, 34, 1.0),
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              ),
            ),
            child: bottomSheet(),
          ),
        );
      },
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
