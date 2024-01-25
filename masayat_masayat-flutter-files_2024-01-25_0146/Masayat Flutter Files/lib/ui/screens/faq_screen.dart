import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/providers/faq_provider.dart';
import '/ui/shared/appbar.dart';
import 'package:provider/provider.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _visible = false;

//  To control scrolling behaviour
  void _scrollToSelectedContent(
      bool isExpanded, double? previousOffset, int index, GlobalKey myKey) {
    final keyContext = myKey.currentContext;

    if (keyContext != null) {
      final box = keyContext.findRenderObject() as RenderBox?;
      _scrollController.animateTo(
          isExpanded ? (box!.size.height * index) : previousOffset!,
          duration: Duration(milliseconds: 500),
          curve: Curves.linear);
    }
  }

//  This list will show all the answers list
  List<Widget> _buildExpansionTileChildren(int index, faqList) => [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            '${faqList[index].answer}',
            textAlign: TextAlign.justify,
            style: TextStyle(
                color: Color.fromRGBO(20, 20, 20, 1.0),
                letterSpacing: 0.7,
                height: 1.4),
          ),
        ),
      ];

//  This Widget will generate list of all question.
  Widget expansionTile(int index, faqList) {
    final GlobalKey expansionTileKey = GlobalKey();
    double? previousOffset;
    return ExpansionTile(
      key: expansionTileKey,
      backgroundColor: Color.fromRGBO(50, 150, 220, 0.05),
      trailing: SizedBox.shrink(),
      onExpansionChanged: (isExpanded) {
        if (isExpanded) previousOffset = _scrollController.offset;
        _scrollToSelectedContent(
            isExpanded, previousOffset, index, expansionTileKey);
      },
      title: Text(
        '${faqList[index].question}',
        style: TextStyle(color: Color.fromRGBO(50, 150, 220, 1.0)),
      ),
      children: _buildExpansionTileChildren(index, faqList),
    );
  }

//  Scaffold body
  Widget scaffoldBody() {
    var faq = Provider.of<FAQProvider>(context);
    var faqList = faq.faqModel!.faqs;
    return ListView.builder(
      controller: _scrollController,
      itemCount: faqList == null ? 0 : faqList.length,
      itemBuilder: (BuildContext context, int index) =>
          expansionTile(index, faqList),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _visible = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      FAQProvider faqProvider =
          Provider.of<FAQProvider>(context, listen: false);
      await faqProvider.fetchFAQ(context);
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
      appBar: customAppBar(context, translate("FAQ_")) as PreferredSizeWidget?,
      body: _visible == false
          ? Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : scaffoldBody(),
    );
  }
}
