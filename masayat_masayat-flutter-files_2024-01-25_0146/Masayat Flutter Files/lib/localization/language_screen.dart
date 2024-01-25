import '/ui/shared/appbar.dart';
import '../localization/language_model.dart';
import '../localization/language_provider.dart';
import '../ui/screens/bottom_navigations_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();
  TextEditingController language = TextEditingController();

  LanguageProvider languageProvider = LanguageProvider();
  List<String> languageList = [];

  @override
  void initState() {
    super.initState();
    languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      for (Language language in (languageProvider.languageModel?.language)!) {
        languageList.add(language.name!);
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, translate("Language_Setting"))
          as PreferredSizeWidget?,
      body: LoadingOverlay(
        isLoading: isLoading,
        progressIndicator: CircularProgressIndicator(),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20.0),
            padding: EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: TextFormField(
                      onTap: () {
                        suggestionPopup(
                            textEditingController: language,
                            list: languageList);
                      },
                      validator: (value) {
                        if ((value?.isEmpty)!) {
                          return translate("Please_choose_Language");
                        }
                        return null;
                      },
                      controller: language,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: translate("Choose_Language"),
                        labelText: translate("Language_"),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Center(
                    child: ElevatedButton(
                      child: Text(
                        translate("Save_"),
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        if ((_formKey.currentState?.validate())!) {
                          _formKey.currentState?.save();

                          setState(() {
                            isLoading = true;
                          });
                          await languageProvider.changeLanguageCode(
                              language: language.text, context: context);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MyBottomNavigationBar(pageInd: 0),
                            ),
                          ).then((value) => setState(() {}));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void suggestionPopup(
      {TextEditingController? textEditingController, List<String>? list}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                Container(
                  height: 250.0,
                  child: SuggestionWidget(
                      textEditingController: textEditingController, list: list),
                ),
              ],
            ),
          );
        });
  }
}

// ignore: must_be_immutable
class SuggestionWidget extends StatefulWidget {
  SuggestionWidget({this.textEditingController, this.list});

  TextEditingController? textEditingController;
  List<String>? list;

  @override
  _SuggestionWidgetState createState() => _SuggestionWidgetState();
}

class _SuggestionWidgetState extends State<SuggestionWidget> {
  TextEditingController controller = TextEditingController();
  String filter = '';

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              autofocus: true,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
                hintText: "Search...",
              ),
              controller: controller,
            )),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: _buildListView(),
          ),
        )
      ],
    );
  }

  Widget _buildListView() {
    return Container(
      height: 300,
      width: 200,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.list?.length,
          itemBuilder: (BuildContext context, int index) {
            if (filter == "") {
              return _buildRow(widget.list![index]);
            } else {
              if (widget.list![index]
                  .toLowerCase()
                  .contains(filter.toLowerCase())) {
                return _buildRow(widget.list![index]);
              } else {
                return Container();
              }
            }
          }),
    );
  }

  Widget _buildRow(String text) {
    return GestureDetector(
      child: ListTile(
        title: Text(text),
      ),
      onTap: () {
        controller.text = text;
        widget.textEditingController?.text = text;
        Navigator.of(context).pop();
      },
    );
  }
}
