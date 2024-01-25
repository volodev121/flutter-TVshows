import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexthour/ui/shared/appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  PdfViewer({
    required this.filePath,
    this.isLocal = false,
    this.isInvoice = false,
  });

  final String filePath;
  final bool isLocal;
  final bool isInvoice;

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final imgUrl =
      "https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf";
  var dio = Dio();
  String _progress = "";

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  void getPermission() async {
    print('get permission');
    await _checkPermission();
  }

  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 29) {
        return true;
      }
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        print(status);
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future download2(Dio dio, String url, String savePath) async {
    //get pdf from link
    Response response = await dio.get(
      url,
      onReceiveProgress: showDownloadProgress,
      //Received data with List<int>
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );

    //write in download folder
    File file = File(savePath);
    var raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();
  }

  void showDownloadProgress(received, total) {
    //progress bar
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
      print("progress $_progress");
      if (_progress == "100%") {
        setState(() {
          _progress = "";
          Fluttertoast.showToast(
              msg: translate("Download_Completed"),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.SNACKBAR,
              timeInSecForIosWeb: 5,
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, translate("Invoice_Download"))
          as PreferredSizeWidget?,
      body: Container(
        child: widget.isLocal
            ? SfPdfViewer.file(File(widget.filePath))
            : SfPdfViewer.network(widget.filePath),
      ),
      floatingActionButton: _progress == ""
          ? FloatingActionButton(
              child: Icon(FontAwesomeIcons.download),
              onPressed: () async {
                print('Download');

                FutureOr<Directory?> path =
                    getExternalStorageDirectory() as FutureOr<Directory>;
                String fullPath = "$path/invoice.pdf";
                download2(dio, imgUrl, fullPath);
              },
            )
          : FloatingActionButton(
              child: CircularProgressIndicator(),
              onPressed: () {},
            ),
    );
  }
}
