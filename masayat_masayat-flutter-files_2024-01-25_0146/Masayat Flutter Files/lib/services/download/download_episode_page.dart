import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import 'package:http/http.dart' as http;
import '/models/datum.dart';
import '/models/progress_data.dart';
import '/models/task_info.dart';
import '/models/todo.dart';
import '/providers/user_profile_provider.dart';
import '../player/downloaded_video_player.dart';
import '../repository/database_creator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:wakelock/wakelock.dart';
import '/models/episode.dart';
import '../repository/repository_service_todo.dart';

// ignore: must_be_immutable
class DownloadEpisodePage extends StatefulWidget {
  DownloadEpisodePage(this.videoDetail, this.sId, this.seasonData, this.dmTask,
      this.dmItems, this.tInfo, this.platform);

  final Datum? videoDetail;
  final sId;
  final seasonData;
  final List<TaskInfo>? dmTask;
  final List<ItemHolder>? dmItems;
  final TaskInfo tInfo;
  TargetPlatform? platform;

  @override
  _DownloadEpisodePageState createState() => _DownloadEpisodePageState();
}

class _DownloadEpisodePageState extends State<DownloadEpisodePage>
    with TickerProviderStateMixin {
  ReceivePort _port = ReceivePort();
  var dFileName;
  Future<List<Todo>>? future;
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
  var ckStatus;
  var newTask;
  List<ItemHolder>? ddItems;
  List<TaskInfo>? ddTasks;
  var dMsg = '';
  var download1, download2, download3, download4, downCount;

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();
    int count = 0;
    ddTasks = [];
    ddItems = [];

    ddTasks!.add(widget.tInfo);
    for (int i = count; i < dTasks!.length; i++) {
      ddItems!.add(ItemHolder(name: ddTasks![i].name, task: ddTasks![i]));
      count++;
    }
    tasks?.forEach((task) {
      for (TaskInfo info in ddTasks!) {
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
            ckStatus = info.status;
            newTask = info;
          });

          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });
    permissionReady = await _checkPermission();
    dLocalPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    final savedDir = Directory(dLocalPath!);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
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
      print('UI Isolate Callback: $data');
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      dynamic progress = data[2];

      if (ddTasks == null) {
        final task = ddTasks?.firstWhere((task) => task.taskId == id);
        if (task != null) {
          print("tt $task");
          setState(() {
            task.status = status;
            task.progress = progress;
          });
        }
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

  void _showDialog(task, userDetails) {
    getAllScreens();
    var downCount;
    if (userDetails.limit == null) {
      Fluttertoast.showToast(
          msg: translate("You_cant_download_with_this_plan"));
      return;
    }

    var limit;
    var totalScreens;

    if (userDetails.limit.runtimeType == int) {
      limit = userDetails.limit;
    } else {
      limit = int.parse(userDetails.limit);
    }
    if (userDetails.screen.runtimeType == int) {
      totalScreens = userDetails.screen;
    } else {
      totalScreens = int.parse(userDetails.screen);
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
    if (dCount.toInt() > downCount || dCount.toInt() == 0) {
      _requestDownload(task);
    } else {
      Fluttertoast.showToast(msg: translate("Your_download_limit_exceed"));
    }
  }

  void _requestDownload360(TaskInfo task) async {
    //  Wakelock.enable();
    setState(() {
      dFileName = task.link360!.split('/').last;
    });
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link360!,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath!,
        showNotification: true,
        openFileFromNotification: false);
    int progress = 0;
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    createTodo(task, task.name, dFileName, mVType, widget.videoDetail!.id,
        widget.seasonData['id'], task.taskId, progress, task.link360);
  }

  void _requestDownload480(TaskInfo task) async {
    // Wakelock.enable();
    setState(() {
      dFileName = task.link480!.split('/').last;
    });
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link480!,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath!,
        showNotification: true,
        openFileFromNotification: false);

    int progress = 0;
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    createTodo(task, task.name, dFileName, mVType, widget.videoDetail!.id,
        widget.seasonData['id'], task.taskId, progress, task.link480);
  }

  void _requestDownload720(TaskInfo task) async {
    // Wakelock.enable();
    setState(() {
      dFileName = task.link720!.split('/').last;
    });
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link720!,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath!,
        showNotification: true,
        openFileFromNotification: false);

    int progress = 0;
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    createTodo(task, task.name, dFileName, mVType, widget.videoDetail!.id,
        widget.seasonData['id'], task.taskId, progress, task.link720);
  }

  void _requestDownload1080(TaskInfo task) async {
    //  Wakelock.enable();
    setState(() {
      dFileName = task.link1080!.split('/').last;
    });
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link1080!,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath!,
        showNotification: true,
        openFileFromNotification: false);

    int progress = 0;
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    createTodo(task, task.name, dFileName, mVType, widget.videoDetail!.id,
        widget.seasonData['id'], task.taskId, progress, task.link1080);
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
                        "Select_Video_Format_in_which_you_want_to_download_video"),
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.7), fontSize: 12.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  widget.seasonData['video_link']['url_360'] == null
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
                                downCount = download1;
                              });
                              if (dCount.toInt() > downCount) {
                                _requestDownload360(task);
                              } else {
                                Fluttertoast.showToast(
                                    msg: translate("Download_limit_exceed"));
                              }
                              Navigator.pop(context);
                            },
                          ),
                        ),
                  widget.seasonData['video_link']['url_480'] == null
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
                                downCount = download2;
                              });
                              _requestDownload480(task);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                  widget.seasonData['video_link']['url_720'] == null
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
                                downCount = download3;
                              });
                              _requestDownload720(task);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                  widget.seasonData['video_link']['url_1080'] == null
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
                                downCount = download4;
                              });
                              _requestDownload1080(task);
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

  Future<String?> getAllScreens() async {
    final getAllScreensResponse =
        await http.get(Uri.parse(APIData.showScreensApi), headers: {
      HttpHeaders.authorizationHeader: "Bearer $authToken",
      "Accept": "application/json"
    });
    var screensRes = json.decode(getAllScreensResponse.body);

    if (getAllScreensResponse.statusCode == 200 &&
        screensRes['screen'] != null) {
      if (mounted) {
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
    }
    return null;
  }

  Widget _buildActionForTask(TaskInfo task) {
    var userDetails =
        Provider.of<UserProfileProvider>(context).userProfileModel;
    if (task.status == DownloadTaskStatus.undefined) {
      return RawMaterialButton(
        onPressed: () {
          if (task.ifLink != "null" ||
              task.hdLink != "null" ||
              task.link360 != "null" ||
              task.link480 != "null" ||
              task.link720 != "null" ||
              task.link1080 != "null") {
            if (task.ifLink != "null") {
              Fluttertoast.showToast(msg: translate("Video_cant_be_download"));
              return;
            } else if (task.hdLink != "null") {
              var matchUrl = "";
              try {
                matchUrl = task.hdLink!.substring(0, 29);
              } catch (e) {
                try {
                  matchUrl = task.hdLink!.substring(0, 23);
                } catch (er) {
                  try {
                    matchUrl = task.hdLink!.substring(0, 18);
                  } catch (er) {
                    throw "String Not Valid";
                  }
                }
              }
              var checkMp4 = task.hdLink!.substring(task.hdLink!.length - 4);
              var checkMpd = task.hdLink!.substring(task.hdLink!.length - 4);
              var checkWebm = task.hdLink!.substring(task.hdLink!.length - 5);
              var checkMkv = task.hdLink!.substring(task.hdLink!.length - 4);
              var checkM3u8 = task.hdLink!.substring(task.hdLink!.length - 5);

              if (matchUrl.substring(0, 18) == "https://vimeo.com/" ||
                  matchUrl.substring(0, 25) == "https://player.vimeo.com/") {
                Fluttertoast.showToast(
                    msg: translate("You_cant_download_this_video"));
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
              } else if (checkMp4 == ".mp4" ||
                  checkMpd == ".mpd" ||
                  checkWebm == ".webm" ||
                  checkMkv == ".mkv" ||
                  checkM3u8 == ".m3u8") {
                getAllScreens();

                if (userDetails!.limit == null) {
                  Fluttertoast.showToast(
                      msg: translate("Cant_download_with_this_plan"));
                  return;
                }
                setState(() {
                  var limit;
                  var totalScreens;

                  if (userDetails.limit.runtimeType == int) {
                    limit = userDetails.limit;
                  } else {
                    limit = int.parse(userDetails.limit);
                  }
                  if (userDetails.screen.runtimeType == int) {
                    totalScreens = userDetails.screen;
                  } else {
                    totalScreens = int.parse(userDetails.screen);
                  }
                  dCount = limit / totalScreens;
                });
                _showDialog(task, userDetails);
              } else {
                Fluttertoast.showToast(
                    msg: translate("Cant_download_this_video"));
                return;
              }
            } else if (mUrl360 != "null" ||
                mUrl480 != "null" ||
                mUrl720 != "null" ||
                mUrl1080 != "null") {
              getAllScreens();
              if (userDetails!.limit == null) {
                Fluttertoast.showToast(
                    msg: translate("Cant_download_with_this_plan"));
                return;
              }
              setState(() {
                dCount = userDetails.limit / userDetails.screen;
              });
              _showMultiDialog(task);
            }
          } else {
            Fluttertoast.showToast(
                msg: translate("Download_link_does_not_exist"));
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
          widget.seasonData['id'], task.taskId, progress, task.hdLink);
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RawMaterialButton(
            onPressed: () {
              //  Wakelock.disable();
              _openDownloadedFile(task);
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
              _retryDownload(task);
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
              _retryDownload(task);
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
    final increaseCounter =
        await http.post(Uri.parse(APIData.downloadCounter), body: {
      "count": '$screenCount',
    }, headers: {
      HttpHeaders.authorizationHeader: "Bearer $authToken"
    });
    print(increaseCounter.statusCode);
  }

  void _delete(TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId!, shouldDeleteContent: true);
    await _prepare();

    setState(() {});
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

  void createTodo(task, taskName, mVideoFileName, videoType, vMovieId,
      episodeId, taskId, progress, url) async {
    checkName(task, taskName, mVideoFileName, videoType, vMovieId, episodeId,
        taskId, progress, url);
  }

  addPersonToDatabase(Todo todo) async {
    var raw = await cdb!.insert(
      DatabaseCreator.todoTable,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }

  Future<Todo?> getPersonWithId(task, taskName, mVideoFileName, videoType,
      vMovieId, episodeId, taskId, progress, url) async {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel;
    int count = await RepositoryServiceTodo.todosCount();
    if (count > 0) {
      var response = await cdb!.query(
        DatabaseCreator.todoTable,
        where:
            "tvseries_id = ? AND vtype = ? AND season_id = ? AND episode_id = ?",
        whereArgs: [vMovieId, videoType, widget.sId, episodeId],
      );
      if (response.isEmpty == true) {
        addPersonToDatabase(Todo(
            id: count,
            name: taskName,
            path: url,
            type: videoType,
            movieId: null,
            tvSeriesId: vMovieId.toString(),
            seasonId: widget.sId.toString(),
            episodeId: episodeId.toString(),
            dTaskId: taskId,
            dUserId: userDetails!.user!.id));
        increaseCounter();
      } else {
        updatePersoneDatabase(ProgressData(dTaskId: taskId, progress: progress),
            vMovieId, videoType);
      }
    } else {
      addPersonToDatabase(
        Todo(
            id: count,
            name: taskName,
            path: url,
            type: videoType,
            movieId: null,
            tvSeriesId: vMovieId.toString(),
            seasonId: widget.sId.toString(),
            episodeId: episodeId.toString(),
            dTaskId: taskId,
            dUserId: userDetails!.user!.id,
            progress: progress),
      );
      increaseCounter();
    }
    return null;
  }

  updatePersoneDatabase(ProgressData pdata, vMovieId, videoType) async {
    var raw = await cdb!.update(
      DatabaseCreator.todoTable,
      pdata.toMap(),
      where: "tvseries_id = ? AND vtype = ? AND progress = ?",
      whereArgs: [vMovieId, videoType, 0],
    );
    return raw;
  }

  void checkName(task, taskName, mVideoFileName, videoType, vMovieId, episodeId,
      taskId, progress, url) async {
    getPersonWithId(task, taskName, mVideoFileName, videoType, vMovieId,
        episodeId, taskId, progress, url);
  }

  void stopScreenLock() async {
    //  Wakelock.enable();
  }

  void _requestDownload(TaskInfo task) async {
    stopScreenLock();
    print("dFilenamelink: ${task.hdLink}");
    setState(() {
      dFileName = task.hdLink!.split('/').last;
    });
    task.taskId = await FlutterDownloader.enqueue(
        url: task.hdLink!,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: dLocalPath!,
        showNotification: true,
        openFileFromNotification: false);
    print("dFilename: $dFileName");
    int progress = 0;
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    createTodo(task, task.name, dFileName, mVType, widget.videoDetail!.id,
        widget.seasonData['id'], task.taskId, progress, task.hdLink);
  }

  void _pauseDownload(TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId!);
  }

  void _resumeDownload(TaskInfo task) async {
    String newTaskId = (await FlutterDownloader.resume(taskId: task.taskId!))!;
    task.taskId = newTaskId;
  }

  void _retryDownload(TaskInfo task) async {
    String newTaskId = (await FlutterDownloader.retry(taskId: task.taskId!))!;
    task.taskId = newTaskId;
  }

  Future<bool?> _openDownloadedFile(TaskInfo? task) async {
    var mVType = widget.videoDetail!.type == DatumType.T ? "T" : "M";
    var response = await cdb!.query(
      DatabaseCreator.todoTable,
      where:
          "tvseries_id = ? AND vtype = ? AND season_id = ? AND episode_id = ?",
      whereArgs: [
        widget.videoDetail!.id,
        mVType,
        widget.sId,
        widget.seasonData['id']
      ],
    );
    var cFileName = response[0]['info'];
    var response2 = await cdb!.query(DatabaseCreator.todoTable);
    print("Res: $response2");

    var newFile = cFileName.toString().split('/').last;

    var router = new MaterialPageRoute(
        builder: (BuildContext context) => DownloadedVideoPlayer(
              taskId: task!.taskId,
              name: task.name,
              fileName: newFile,
              downloadStatus: 0,
            ));
    Navigator.of(context).push(router);

    return null;
  }

  Widget column() {
    var userDetails =
        Provider.of<UserProfileProvider>(context).userProfileModel;
    if (download == 0) {
      return Column(
        children: <Widget>[
          IconButton(
              icon: Icon(
                Icons.file_download,
                size: 30,
              ),
              onPressed: () {
                Fluttertoast.showToast(msg: translate("Downloading_is_OFF"));
              }),
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
      );
    } else {
      return userDetails!.active == "1"
          ? userDetails.payment == "Free"
              ? Column(
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.file_download),
                        onPressed: () {
                          Fluttertoast.showToast(
                              msg: translate(
                                  "You_cannot_download_with_free_plan"));
                        }),
                  ],
                )
              : Builder(
                  builder: (context) => isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : permissionReady
                          ? ddItems == null
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Container(
                                  child: Column(
                                    children: ddItems!
                                        .map((item) => item.task == null
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 8.0),
                                                child: Text(
                                                  item.name!,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                      fontSize: 18.0),
                                                ),
                                              )
                                            : Container(
                                                child: InkWell(
                                                  onTap:
                                                      item.task!.status ==
                                                              DownloadTaskStatus
                                                                  .complete
                                                          ? () {
                                                              _openDownloadedFile(
                                                                      item.task)
                                                                  .then(
                                                                (success) {
                                                                  if (!success!) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(translate('Cannot_open_this_file')),
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                              );
                                                            }
                                                          : null,
                                                  child: Stack(
                                                    children: <Widget>[
                                                      new Container(
                                                        height: 62.0,
                                                        child:
                                                            _buildActionForTask(
                                                                item.task!),
                                                      ),
                                                      item.task!.status ==
                                                                  DownloadTaskStatus
                                                                      .running ||
                                                              item.task!
                                                                      .status ==
                                                                  DownloadTaskStatus
                                                                      .paused
                                                          ? new Positioned(
                                                              left: 15.0,
                                                              right: 15.0,
                                                              bottom: 0.0,
                                                              child:
                                                                  LinearProgressIndicator(
                                                                value: item
                                                                        .task!
                                                                        .progress! /
                                                                    100,
                                                              ),
                                                            )
                                                          : Container()
                                                    ]
                                                        .where((child) => true)
                                                        .toList(),
                                                  ),
                                                ),
                                              ))
                                        .toList(),
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
                                            color: Colors.blueGrey,
                                            fontSize: 18.0),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 32.0,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _checkPermission().then((hasGranted) {
                                          setState(() {
                                            permissionReady = hasGranted;
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
          : Column(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: () {
                      _showMsg();
                    }),
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
            );
    }
  }

  void _showMsg() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    if (userDetails.paypal!.length == 0 ||
        userDetails.user!.subscriptions?.length == 0 ||
        userDetails.user!.subscriptions == null) {
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

  @override
  void initState() {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    isLoading = false;
    permissionReady = true;
    _prepare();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final userProfile =
          Provider.of<UserProfileProvider>(context, listen: false)
              .userProfileModel!;
      if (userProfile.active == "1") {
        getAllScreens();
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
    _prepare();
    return Expanded(
      flex: 2,
      child: Material(
        child: column(),
        color: Colors.transparent,
      ),
    );
  }
}
