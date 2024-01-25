import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import 'package:http/http.dart' as http;
import '/common/route_paths.dart';
import '/models/datum.dart';
import '/models/progress_data.dart';
import '/models/task_info.dart';
import '/models/todo.dart';
import '/models/user_profile_model.dart';
import '/providers/user_profile_provider.dart';
import '/services/player/downloaded_video_player.dart';
import '/services/repository/database_creator.dart';
import '/services/repository/repository_service_todo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:wakelock/wakelock.dart';
import '/models/episode.dart';

// ignore: must_be_immutable
class DownloadPage extends StatefulWidget {
  DownloadPage(this.videoDetail, this.platform);
  TargetPlatform? platform;
  final Datum? videoDetail;

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with TickerProviderStateMixin {
  var readyCompleter = Completer();

  Future get ready => readyCompleter.future;
  late bool _permissionReady;
  ReceivePort _port = ReceivePort();
  var dFileName;
  List x = [];
  dynamic id;
  var mtName,
      mReadyUrl,
      mIFrameUrl,
      mUrl360,
      mUrl480,
      mUrl720,
      mUrl1080,
      youtubeUrl,
      vimeoUrl;

  var dMsg = '';
  var download1, download2, download3, download4, downCount;

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();
    int count = 0;
    dTasks = [];
    dItems = [];

    dTasks!.add(
      TaskInfo(
        name: "${widget.videoDetail!.title}",
        ifLink: widget.videoDetail!.videoLink == null
            ? null
            : "${widget.videoDetail!.videoLink!.iframeurl}",
        hdLink: widget.videoDetail!.videoLink == null
            ? null
            : widget.videoDetail!.videoLink!.readyUrl != null
                ? "${widget.videoDetail!.videoLink!.readyUrl}"
                : "${widget.videoDetail!.videoLink!.uploadVideo}",
        link360: widget.videoDetail!.videoLink == null
            ? null
            : "${widget.videoDetail!.videoLink!.url360}",
        link480: widget.videoDetail!.videoLink == null
            ? null
            : "${widget.videoDetail!.videoLink!.url480}",
        link720: widget.videoDetail!.videoLink == null
            ? null
            : "${widget.videoDetail!.videoLink!.url720}",
        link1080: widget.videoDetail!.videoLink == null
            ? null
            : "${widget.videoDetail!.videoLink!.url1080}",
      ),
    );

    for (int i = count; i < dTasks!.length; i++) {
      dItems!.add(ItemHolder(name: dTasks![i].name, task: dTasks![i]));
      count++;
    }

    tasks?.forEach((task) {
      for (TaskInfo info in dTasks!) {
        if (info.hdLink == task.url ||
            info.ifLink == task.url ||
            info.link360 == task.url ||
            info.link480 == task.url ||
            info.link720 == task.url ||
            info.link1080 == task.url) {
          setState(() {
            mReadyUrl = info.hdLink;
            mIFrameUrl = info.ifLink;
            mUrl360 = info.link360;
            mUrl480 = info.link480;
            mUrl720 = info.link720;
            mUrl1080 = info.link1080;
          });
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    _permissionReady = await _checkPermission();
    dLocalPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    final savedDir = Directory(dLocalPath!);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String> _findLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<bool> _checkPermission() async {
    if (widget.platform == TargetPlatform.android) {
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
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_senddPort');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) {
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      dynamic progress = data[2];

      final task = dTasks?.firstWhereOrNull((task) => task.taskId == id);

      if (task != null) {
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_senddPort');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_senddPort')!;
    send.send([id, status, progress]);
  }

  void _showDialog(task) {
    var userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false)
            .userProfileModel!;
    getAllScreens();
    int downCount = 0;
    // userProfileProvider.limit = 5;
    if (userProfileProvider.limit == null) {
      Fluttertoast.showToast(
          msg: translate("You_cant_download_with_this_plan"));
      return;
    }
    var limit;
    var totalScreens;

    if (userProfileProvider.limit.runtimeType == int) {
      limit = userProfileProvider.limit;
    } else {
      limit = int.parse(userProfileProvider.limit);
    }
    if (userProfileProvider.screen.runtimeType == int) {
      totalScreens = userProfileProvider.screen;
    } else {
      totalScreens = int.parse(userProfileProvider.screen);
    }
    var dCount = limit / totalScreens;
    if (screenCount == "1" || screenCount == 1) {
      setState(() {
        downCount = download1;
      });
    } else if (screenCount == "2" || screenCount == 2) {
      setState(() {
        downCount = download2;
      });
    } else if (screenCount == "3" || screenCount == 3) {
      setState(() {
        downCount = download3;
      });
    } else if (screenCount == "4" || screenCount == 4) {
      setState(() {
        downCount = download4;
      });
    }
    print(downCount.runtimeType);
    if (dCount.toInt() > downCount || dCount.toInt() == 0) {
      _requestDownload(task);
    } else {
      Fluttertoast.showToast(msg: translate("Your_download_limit_exceed"));
    }
  }

  Future<String?> getAllScreens() async {
    final getAllScreensResponse =
        await http.get(Uri.parse(APIData.showScreensApi), headers: {
      HttpHeaders.authorizationHeader: "Bearer $authToken",
      'Content-Type': 'application/x-www-form-urlencoded',
    });
    var screensRes = json.decode(getAllScreensResponse.body);
    print("limit: ${screensRes['screen']}");
    if (getAllScreensResponse.statusCode == 200) {
      setState(() {
        download1 = screensRes['screen']['download_1'] == null
            ? 0
            : screensRes['screen']['download_1'];
        download2 = screensRes['screen']['download_2'] == null
            ? 0
            : screensRes['screen']['download_2'];
        download3 = screensRes['screen']['download_3'] == null
            ? 0
            : screensRes['screen']['download_3'];
        download4 = screensRes['screen']['download_4'] == null
            ? 0
            : screensRes['screen']['download_4'];
      });
    }
    return null;
  }

  void _showMultiDialog(task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            backgroundColor: Color.fromRGBO(250, 250, 250, 1.0),
            title: Text(
              translate("Video_Quality"),
              style: TextStyle(
                  color: Color.fromRGBO(72, 163, 198, 1.0),
                  fontWeight: FontWeight.w600,
                  fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            content: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    translate(
                        "Available_Video_Format_in_which_you_want_to_download_video"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.7), fontSize: 12.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  widget.videoDetail!.videoLink!.url360 == "null"
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                activeDotColor,
                              ),
                              overlayColor: MaterialStateProperty.all<Color?>(
                                Color.fromRGBO(72, 163, 198, 1.0),
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 30.0,
                              child: Text("360"),
                            ),
                            onPressed: () {
                              setState(() {
                                if (screenCount == "1" || screenCount == 1) {
                                  setState(() {
                                    downCount = download1;
                                  });
                                } else if (screenCount == "2" ||
                                    screenCount == 2) {
                                  setState(() {
                                    downCount = download2;
                                  });
                                } else if (screenCount == "3" ||
                                    screenCount == 3) {
                                  setState(() {
                                    downCount = download3;
                                  });
                                } else if (screenCount == "4" ||
                                    screenCount == 4) {
                                  setState(() {
                                    downCount = download4;
                                  });
                                }
                              });
                              print("screenCount :$dCount");
                              if (dCount.toInt() > downCount ||
                                  dCount.toInt() == 0) {
                                if (task.link360 == 'null' ||
                                    task.link360 == null) {
                                  Fluttertoast.showToast(
                                      msg: translate(
                                          "This_Video_cant_be_downloaded"));
                                } else {
                                  _requestDownload360(task);
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: translate("Download_limit_exceed"));
                              }
                              Navigator.pop(context);
                            },
                          ),
                        ),
                  widget.videoDetail!.videoLink!.url480 == "null"
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                activeDotColor,
                              ),
                              overlayColor: MaterialStateProperty.all<Color?>(
                                Color.fromRGBO(72, 163, 198, 1.0),
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 30.0,
                              child: Text("480"),
                            ),
                            onPressed: () {
                              setState(() {
                                setState(() {
                                  if (screenCount == "1" || screenCount == 1) {
                                    setState(() {
                                      downCount = download1;
                                    });
                                  } else if (screenCount == "2" ||
                                      screenCount == 2) {
                                    setState(() {
                                      downCount = download2;
                                    });
                                  } else if (screenCount == "3" ||
                                      screenCount == 3) {
                                    setState(() {
                                      downCount = download3;
                                    });
                                  } else if (screenCount == "4" ||
                                      screenCount == 4) {
                                    setState(() {
                                      downCount = download4;
                                    });
                                  }
                                });
                              });
                              if (dCount.toInt() > downCount ||
                                  dCount.toInt() == 0) {
                                if (task.link480 == 'null' ||
                                    task.link480 == null) {
                                  Fluttertoast.showToast(
                                      msg: translate(
                                          "This_Video_cant_be_downloaded"));
                                } else {
                                  _requestDownload480(task);
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: translate("Download_limit_exceed"));
                              }

                              Navigator.pop(context);
                            },
                          ),
                        ),
                  widget.videoDetail!.videoLink!.url720 == "null"
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                activeDotColor,
                              ),
                              overlayColor: MaterialStateProperty.all<Color?>(
                                Color.fromRGBO(72, 163, 198, 1.0),
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 30.0,
                              child: Text("720"),
                            ),
                            onPressed: () {
                              setState(() {
                                if (screenCount == "1" || screenCount == 1) {
                                  setState(() {
                                    downCount = download1;
                                  });
                                } else if (screenCount == "2" ||
                                    screenCount == 2) {
                                  setState(() {
                                    downCount = download2;
                                  });
                                } else if (screenCount == "3" ||
                                    screenCount == 3) {
                                  setState(() {
                                    downCount = download3;
                                  });
                                } else if (screenCount == "4" ||
                                    screenCount == 4) {
                                  setState(() {
                                    downCount = download4;
                                  });
                                }
                              });
                              if (dCount.toInt() > downCount ||
                                  dCount.toInt() == 0) {
                                if (task.link720 == 'null' ||
                                    task.link720 == null) {
                                  Fluttertoast.showToast(
                                      msg: translate(
                                          "This_Video_cant_be_downloaded"));
                                } else {
                                  _requestDownload720(task);
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: translate("Download_limit_exceed"));
                              }

                              Navigator.pop(context);
                            },
                          ),
                        ),
                  widget.videoDetail!.videoLink!.url1080 == "null"
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 50.0, right: 50.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                activeDotColor,
                              ),
                              overlayColor: MaterialStateProperty.all<Color?>(
                                Color.fromRGBO(72, 163, 198, 1.0),
                              ),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0,
                              height: 30.0,
                              child: Text("1080"),
                            ),
                            onPressed: () {
                              setState(() {
                                setState(() {
                                  if (screenCount == "1" || screenCount == 1) {
                                    setState(() {
                                      downCount = download1;
                                    });
                                  } else if (screenCount == "2" ||
                                      screenCount == 2) {
                                    setState(() {
                                      downCount = download2;
                                    });
                                  } else if (screenCount == "3" ||
                                      screenCount == 3) {
                                    setState(() {
                                      downCount = download3;
                                    });
                                  } else if (screenCount == "4" ||
                                      screenCount == 4) {
                                    setState(() {
                                      downCount = download4;
                                    });
                                  }
                                });
                              });
                              if (dCount.toInt() > downCount ||
                                  dCount.toInt() == 0) {
                                if (task.link1080 == 'null' ||
                                    task.link1080 == null) {
                                  Fluttertoast.showToast(
                                      msg: translate(
                                          "This_Video_cant_be_downloaded"));
                                } else {
                                  _requestDownload1080(task);
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: translate("Download_limit_exceed"));
                              }

                              Navigator.pop(context);
                            },
                          ),
                        ),
                ],
              ),
            ));
      },
    );
  }

  Widget _buildActionForTask(TaskInfo task) {
    var userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false)
            .userProfileModel;
    if (task.status == DownloadTaskStatus.undefined) {
      return RawMaterialButton(
        onPressed: () {
          if (widget.videoDetail!.videoLink == null) {
            Fluttertoast.showToast(msg: translate("Video_URL_does_not_exist"));
            return;
          }

          mIFrameUrl = widget.videoDetail!.videoLink!.iframeurl;
          if (mIFrameUrl == "null") {
            setState(() {
              mIFrameUrl = null;
            });
          }
          print("Iframe: $mIFrameUrl");
          mReadyUrl = widget.videoDetail!.videoLink!.readyUrl;
          if (mReadyUrl == "null") {
            setState(() {
              mReadyUrl = null;
            });
          }
          print("Ready Url: $mReadyUrl");
          mUrl360 = widget.videoDetail!.videoLink!.url360;
          if (mUrl360 == "null") {
            setState(() {
              mUrl360 = null;
            });
          }
          print("Url 360: $mUrl360");
          mUrl480 = widget.videoDetail!.videoLink!.url480;
          if (mUrl480 == "null") {
            setState(() {
              mUrl480 = null;
            });
          }
          print("Url 480: $mUrl480");
          mUrl720 = widget.videoDetail!.videoLink!.url720;
          if (mUrl720 == "null") {
            setState(() {
              mUrl720 = null;
            });
          }
          print("Url 720: $mUrl720");
          mUrl1080 = widget.videoDetail!.videoLink!.url1080;
          if (mUrl1080 == "null") {
            setState(() {
              mUrl1080 = null;
            });
          }
          print("Url 1080: $mUrl1080");

          mReadyUrl = widget.videoDetail!.videoLink!.uploadVideo;
          if (mReadyUrl == "null") {
            setState(() {
              mReadyUrl = null;
            });
          }
          print("Ready Url: $mReadyUrl");

          if (mIFrameUrl != null ||
              mReadyUrl != null ||
              mUrl360 != null ||
              mUrl480 != null ||
              mUrl720 != null ||
              mUrl1080 != null) {
            if (mIFrameUrl != null) {
              Fluttertoast.showToast(
                  msg: translate("Cant_download_this_video"));
              return;
            } else if (mReadyUrl != null) {
              print("Ready URL Condition");
              var checkMp42 = mReadyUrl.substring(mReadyUrl.length - 4);
              print("Ready URL Condition: $mReadyUrl");
              print("Ready URL Condition: $checkMp42");

              RegExp vimeoExp = new RegExp(
                "https://vimeo.com",
                caseSensitive: false,
              );
              RegExp vimeoExp1 = new RegExp(
                "https://player.vimeo.com",
                caseSensitive: false,
              );
              bool vimeo =
                  vimeoExp.hasMatch(mReadyUrl) || vimeoExp1.hasMatch(mReadyUrl);
              print("Ready URL Condition: $vimeo");
              var matchUrl = "";
              try {
                matchUrl = mReadyUrl.substring(0, 29);
              } catch (e) {
                try {
                  matchUrl = mReadyUrl.substring(0, 23);
                } catch (er) {
                  try {
                    matchUrl = mReadyUrl.substring(0, 18);
                  } catch (er) {
                    throw "String Not Valid";
                  }
                }
              }
              var checkMp4 = mReadyUrl.substring(mReadyUrl.length - 4);
              var checkMpd = mReadyUrl.substring(mReadyUrl.length - 4);
              var checkWebm = mReadyUrl.substring(mReadyUrl.length - 5);
              var checkMkv = mReadyUrl.substring(mReadyUrl.length - 4);
              var checkM3u8 = mReadyUrl.substring(mReadyUrl.length - 5);

              if (matchUrl.substring(0, 18) == "https://vimeo.com/" ||
                  matchUrl.substring(0, 25) == "https://player.vimeo.com/") {
                Fluttertoast.showToast(
                    msg: translate("Cant_download_this_video"));
                return;
              } else if (matchUrl == 'https://www.youtube.com/embed') {
                Fluttertoast.showToast(
                    msg: translate("Cant_download_this_video"));
                return;
              } else if (matchUrl.substring(0, 23) ==
                  'https://www.youtube.com') {
                Fluttertoast.showToast(
                    msg: translate("Cant_download_this_video"));
                return;
              } else if (matchUrl.substring(0, 29) ==
                  'https://drive.google.com/file/') {
                Fluttertoast.showToast(
                    msg: translate("Cant_download_this_video"));
                return;
              } else if (matchUrl.substring(0, 29) ==
                  'https://drive.google.com/file/') {
                Fluttertoast.showToast(
                    msg: translate("Cant_download_this_video"));
                return;
              } else if (checkMp4 == ".mp4" ||
                  checkWebm == ".webm" ||
                  checkMkv == ".mkv" ||
                  checkMpd == ".mpd" ||
                  checkM3u8 == ".m3u8") {
                _showDialog(task);
              } else {
                Fluttertoast.showToast(
                    msg: translate("Cant_download_this_video"));
                return;
              }
            } else if (mUrl360 != null ||
                mUrl480 != null ||
                mUrl720 != null ||
                mUrl1080 != null) {
              getAllScreens();
              print("active: ${userProfileProvider!.active}");
              print("code: ${userProfileProvider.code}");
              print("currentDate: ${userProfileProvider.currentDate}");
              print(
                  "currentSubscription: ${userProfileProvider.currentSubscription}");
              print("end: ${userProfileProvider.end}");
              print("id: ${userProfileProvider.id}");
              print("limit: ${userProfileProvider.limit}");
              print("screen: ${userProfileProvider.screen}");
              if (userProfileProvider.limit == null) {
                Fluttertoast.showToast(
                    msg: translate("Cant_download_with_this_plan"));
                return;
              }
              setState(() {
                if (userProfileProvider.limit == 0 ||
                    userProfileProvider.limit == "0") {
                  dCount = 0;
                } else {
                  var limit;
                  var totalScreens;

                  if (userProfileProvider.limit.runtimeType == int) {
                    limit = userProfileProvider.limit;
                  } else {
                    limit = int.parse(userProfileProvider.limit ?? '10');
                  }
                  if (userProfileProvider.screen.runtimeType == int) {
                    totalScreens = userProfileProvider.screen;
                  } else {
                    totalScreens = int.parse(userProfileProvider.screen);
                  }
                  dCount = limit / totalScreens;
                }
              });
              _showMultiDialog(task);
            } else {
              Fluttertoast.showToast(
                  msg: translate("Cant_download_this_video"));
              return;
            }
          } else {
            Fluttertoast.showToast(msg: translate("Video_URL_does_not_exist"));
          }
        },
        child: Icon(
          Icons.file_download,
          size: 30.0,
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 30.0, minWidth: 30.0),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return new RawMaterialButton(
        onPressed: () {
          _pauseDownload(task);
        },
        onLongPress: () {
          _showDialog3(task);
        },
        child: Icon(
          Icons.pause,
          color: Colors.red,
          size: 30.0,
        ),
        shape: new CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return new RawMaterialButton(
        onPressed: () {
          _resumeDownload(task);
        },
        onLongPress: () {
          _showDialog3(task);
        },
        child: Icon(
          Icons.play_arrow,
          color: Colors.green,
          size: 30.0,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      int progress = 100;
      var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
      createTodo(task, task.name, dFileName, mVType, widget.videoDetail!.id,
          task.taskId, progress, task.hdLink);
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RawMaterialButton(
            onPressed: () {
              //  Wakelock.disable();
              _openDownloadedFile(task);
            },
            onLongPress: () {
              _showDeleteDialog(task);
            },
            child: Icon(
              Icons.file_download,
              color: activeDotColor,
              size: 30.0,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(translate('Failed_'), style: TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              _showDialog(task);
            },
            onLongPress: () {
              _showDialog3(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(translate('Failed_'), style: TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              _showDialog(task);
            },
            onLongPress: () {
              _showDialog3(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  increaseCounter() async {
    var screenCount = await storage.read(key: "screenCount");
    await http.post(
      Uri.parse(APIData.downloadCounter),
      body: {
        "count": '$screenCount',
      },
      headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"},
    );
  }

  void _showDialog3(task) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: new Text(
            translate("Stop_Download"),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          content: new Text(
            translate("Do_you_want_to_cancel"),
            style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 16.0),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text(
                translate("Yes_"),
                style: TextStyle(color: activeDotColor, fontSize: 16.0),
              ),
              onPressed: () {
                _delete(task);
                Navigator.pop(context);
              },
            ),
            new TextButton(
              child: new Text(
                translate("No_"),
                style: TextStyle(color: activeDotColor, fontSize: 16.0),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(task) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: new Text(
            translate("Delete_Downloaded"),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          content: new Text(
            translate("Do_you_want_to_delete"),
            style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 16.0),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text(
                translate("Yes_"),
                style: TextStyle(color: activeDotColor, fontSize: 16.0),
              ),
              onPressed: () {
                _delete(task);
                Navigator.pop(context);
              },
            ),
            new TextButton(
              child: new Text(
                translate("No_"),
                style: TextStyle(color: activeDotColor, fontSize: 16.0),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future checkConn(task) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      print('not connected');
      _pauseDownload(task);
    }
  }

  void _delete(TaskInfo task) async {
    print("row; ${task.taskId}");
    if (!_permissionReady) {
      print("not permited");
      _checkPermission();
    } else {
      _delete2(task);
    }
  }

  void _delete2(TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId!, shouldDeleteContent: true);
    await _prepare();
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    await cdb!.delete(
      DatabaseCreator.todoTable,
      where: "movie_id = ? AND vtype = ?",
      whereArgs: ['${widget.videoDetail!.id}', '$mVType'],
    );

    setState(() {});
  }

  void createTodo(task, taskName, mVideoFileName, videoType, vMovieId, taskId,
      progress, url) async {
    checkName(task, taskName, mVideoFileName, videoType, vMovieId, taskId,
        progress, url);
  }

  addPersonToDatabase(Todo todo) async {
    var raw = await cdb!.insert(
      DatabaseCreator.todoTable,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }

  updatePersoneDatabase(ProgressData pdata, vMovieId, videoType) async {
    var raw = await cdb!.update(
      DatabaseCreator.todoTable,
      pdata.toMap(),
      where: "movie_id = ? AND vtype = ? AND progress = ?",
      whereArgs: [vMovieId, videoType, 0],
    );
    return raw;
  }

  Future<Todo?> getPersonWithId(task, taskName, mVideoFileName, videoType,
      vMovieId, taskId, progress, url) async {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!
        .user;

    int count = await RepositoryServiceTodo.todosCount();
    if (count > 0) {
      var response = await cdb!.query(
        DatabaseCreator.todoTable,
        where: "movie_id = ? AND vtype = ?",
        whereArgs: [vMovieId, videoType],
      );
      if (response.isEmpty == true) {
        addPersonToDatabase(Todo(
            id: count,
            name: taskName,
            path: url,
            type: videoType,
            movieId: vMovieId.toString(),
            tvSeriesId: null,
            seasonId: null,
            episodeId: null,
            dTaskId: taskId,
            dUserId: userDetails!.id,
            progress: progress));
        increaseCounter();
      } else {
        updatePersoneDatabase(ProgressData(dTaskId: taskId, progress: progress),
            vMovieId, videoType);
      }
    } else {
      addPersonToDatabase(Todo(
          id: count,
          name: taskName,
          path: url,
          type: videoType,
          movieId: vMovieId.toString(),
          tvSeriesId: null,
          seasonId: null,
          episodeId: null,
          dTaskId: taskId,
          dUserId: userDetails!.id,
          progress: progress));
      increaseCounter();
    }
    return null;
  }

  void checkName(task, taskName, mVideoFileName, videoType, vMovieId, taskId,
      progress, url) async {
    getPersonWithId(task, taskName, mVideoFileName, videoType, vMovieId, taskId,
        progress, url);
  }

  saveNewFileName(dFileName) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('dFileName', "$dFileName");
  }

  void _requestDownload(TaskInfo task) async {
    //  Wakelock.enable();
    setState(() {
      dFileName = task.hdLink!.split('/').last;
    });
    saveNewFileName(dFileName);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.hdLink!,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath!,
        showNotification: true,
        openFileFromNotification: false);

    int progress = 0;
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    createTodo(task, task.name, dFileName, mVType, widget.videoDetail!.id,
        task.taskId, progress, task.hdLink);
  }

  void _requestDownload360(TaskInfo task) async {
    //  Wakelock.enable();
    setState(() {
      dFileName = task.link360!.split('/').last;
    });
    saveNewFileName(dFileName);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link360!,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath!,
        showNotification: true,
        openFileFromNotification: false);

    int progress = 0;
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    createTodo(task, task.name, dFileName, mVType, widget.videoDetail!.id,
        task.taskId, progress, task.link360);
  }

  void _requestDownload480(TaskInfo task) async {
    //  Wakelock.enable();
    setState(() {
      dFileName = task.link480!.split('/').last;
    });
    saveNewFileName(dFileName);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link480!,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath!,
        showNotification: true,
        openFileFromNotification: false);

    int progress = 0;
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    createTodo(task, task.name, dFileName, mVType, widget.videoDetail!.id,
        task.taskId, progress, task.link480);
  }

  void _requestDownload720(TaskInfo task) async {
    // Wakelock.enable();
    setState(() {
      dFileName = task.link720!.split('/').last;
    });
    saveNewFileName(dFileName);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link720!,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath!,
        showNotification: true,
        openFileFromNotification: false);

    int progress = 0;
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    createTodo(task, task.name, dFileName, mVType, widget.videoDetail!.id,
        task.taskId, progress, task.link720);
  }

  void _requestDownload1080(TaskInfo task) async {
    //  Wakelock.enable();

    setState(() {
      dFileName = task.link1080!.split('/').last;
    });
    saveNewFileName(dFileName);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link1080!,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath!,
        showNotification: true,
        openFileFromNotification: false);

    int progress = 0;
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    createTodo(task, task.name, dFileName, mVType, widget.videoDetail!.id,
        task.taskId, progress, task.link1080);
  }

  void _pauseDownload(TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId!);
  }

  void _resumeDownload(TaskInfo task) async {
    String newTaskId = (await FlutterDownloader.resume(taskId: task.taskId!))!;
    task.taskId = newTaskId;
  }

  Future<bool?> _openDownloadedFile(TaskInfo? task) async {
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    var response = await cdb!.query(
      DatabaseCreator.todoTable,
      where: "movie_id = ? AND vtype = ?",
      whereArgs: [widget.videoDetail!.id, mVType],
    );
    var cFileName = response[0]['info'];

    var fileNamenew = cFileName.toString().split('/').last;

    var router = new MaterialPageRoute(
        builder: (BuildContext context) => DownloadedVideoPlayer(
              taskId: task!.taskId,
              name: task.name,
              fileName: fileNamenew,
              downloadStatus: 0,
            ));
    Navigator.of(context).push(router);

    return null;
  }

//  Download text
  Widget downloadText(TaskInfo task) {
    return task.status == DownloadTaskStatus.complete
        ? Text(
            translate("Downloaded_"),
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                color: activeDotColor),
          )
        : Text(
            translate("Download_"),
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
          );
  }

  void _showMsg(UserProfileModel userDetails) {
    if (userDetails.paypal!.length == 0 ||
        userDetails.user!.subscriptions == null ||
        userDetails.user!.subscriptions!.length == 0) {
      dMsg = translate(
              "Watch_unlimited_movies_TV_shows_and_videos_in_HD_or_SD_quality") +
          " " +
          translate("You_dont_have_subscribe");
    } else {
      dMsg = translate(
              "Watch_unlimited_movies_TV_shows_and_videos_in_HD_or_SD_quality") +
          " " +
          translate("You_dont_have_any_active_subscription_plan");
    }
    // set up the button
    Widget cancelButton = TextButton(
      child: Text(
        translate("Cancel_"),
        style: TextStyle(color: activeDotColor, fontSize: 16.0),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget subscribeButton = TextButton(
      child: Text(
        translate("Subscribe_"),
        style: TextStyle(color: activeDotColor, fontSize: 16.0),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, RoutePaths.subscriptionPlans);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      contentPadding:
          EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0, bottom: 0.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            translate("Subscribe_Plans"),
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
      content: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Text(
              "$dMsg",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
      actions: [
        subscribeButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget column() {
    var userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false)
            .userProfileModel;
    if (download == 0) {
      return GestureDetector(
        onTap: () {
          Fluttertoast.showToast(msg: translate("Downloading_is_OFF"));
        },
        child: Column(
          children: <Widget>[
            Icon(
              Icons.file_download,
              size: 30,
            ),
            SizedBox(height: 10.0),
            Text(
              translate("Download_"),
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      );
    } else {
      return userProfileProvider!.active == "1"
          ? Builder(
              builder: (context) => isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _permissionReady
                      ? Container(
                          child: Column(
                            children: dItems!.map((item) {
                              checkConn(item.task);
                              return item.task == null
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      child: Text(
                                        item.name!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                            fontSize: 18.0),
                                      ),
                                    )
                                  : Container(
                                      child: InkWell(
                                        onTap: item.task!.status ==
                                                DownloadTaskStatus.complete
                                            ? () {
                                                _openDownloadedFile(item.task)
                                                    .then((success) {
                                                  if (!success!) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(translate(
                                                            'Cannot_open_this_file')),
                                                      ),
                                                    );
                                                  }
                                                });
                                              }
                                            : null,
                                        child: Stack(
                                          children: <Widget>[
                                            new Container(
                                              width: double.infinity,
                                              margin:
                                                  EdgeInsets.only(bottom: 10.0),
                                              height: 62.0,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  _buildActionForTask(
                                                      item.task!),
                                                  downloadText(item.task!),
                                                ],
                                              ),
                                            ),
                                            item.task!.status ==
                                                        DownloadTaskStatus
                                                            .running ||
                                                    item.task!.status ==
                                                        DownloadTaskStatus
                                                            .paused
                                                ? new Positioned(
                                                    left: 15.0,
                                                    right: 15.0,
                                                    bottom: 0.0,
                                                    child:
                                                        LinearProgressIndicator(
                                                      value:
                                                          item.task!.progress! /
                                                              100,
                                                    ),
                                                  )
                                                : Container()
                                          ]
                                              .where((child) => child == child)
                                              .toList(),
                                        ),
                                      ),
                                    );
                            }).toList(),
                          ),
                        )
                      : Container(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0),
                                  child: Text(
                                    translate(
                                            'Please_grant_accessing_storage_permission_to_continue') +
                                        ' -_-',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.blueGrey, fontSize: 18.0),
                                  ),
                                ),
                                SizedBox(
                                  height: 32.0,
                                ),
                                TextButton(
                                  onPressed: () {
                                    _checkPermission().then((hasGranted) {
                                      setState(() {
                                        _permissionReady = hasGranted;
                                      });
                                    });
                                  },
                                  child: Text(
                                    translate('Retry_'),
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
            )
          : GestureDetector(
              onTap: () {
                _showMsg(userProfileProvider);
              },
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.file_download,
                    size: 30.0,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    translate("Download_"),
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
            );
    }
  }

  getNewFileName() async {
    prefs = await SharedPreferences.getInstance();
    prefs.getString('dFileName');
    setState(() {
      downFileName = prefs.getString('dFileName');
    });
  }

  @override
  void initState() {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    isLoading = true;
    _permissionReady = false;
    _prepare();
    getNewFileName();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final userProfileProvider =
          Provider.of<UserProfileProvider>(context, listen: false)
              .userProfileModel!;
      if (userProfileProvider.active == "1") {
        if (userProfileProvider.payment != "Free") {
          getAllScreens();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        child: column(),
        color: Colors.transparent,
      ),
    );
  }
}
