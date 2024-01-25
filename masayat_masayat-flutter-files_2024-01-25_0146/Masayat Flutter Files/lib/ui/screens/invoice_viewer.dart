import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nexthour/common/apipath.dart';
import 'package:nexthour/common/global.dart';
import 'package:nexthour/ui/screens/pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class InvoiceDownload extends StatefulWidget {
  InvoiceDownload(this.id);
  int id;
  @override
  _InvoiceDownloadState createState() => _InvoiceDownloadState();
}

class _InvoiceDownloadState extends State<InvoiceDownload> {
  Future<void> loadData() async {
    String? accessToken = await storage.read(key: "authToken");
    String url = "${APIData.invoice}${widget.id}?secret=" + APIData.secretKey;

    http.Response response = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: "Bearer $accessToken",
    });
    print(response.statusCode);
    if (response.statusCode == 200) {
      Uint8List bytes = response.bodyBytes;
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = File(
          "$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".pdf");
      await file.writeAsBytes(bytes);
      var filePath = file.path;
      print(filePath);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewer(
            filePath: filePath,
            isLocal: true,
            isInvoice: true,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white.withOpacity(0.2),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
