import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/services/player/downloaded_video_player.dart';
import '/services/repository/database_creator.dart';
import '/ui/shared/appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'blank_download_list.dart';

var debug = true;

class DownloadedVideos extends StatefulWidget with WidgetsBindingObserver {
  DownloadedVideos({
    Key? key,
  }) : super(key: key);

  @override
  _DownloadedVideosState createState() => new _DownloadedVideosState();
}

class _DownloadedVideosState extends State<DownloadedVideos> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  List<_TaskInfo>? _tasks;
  late List<_ItemHolder> _items;
  late bool _isLoading;
  late bool _permissionReady;
  late String _localPath;
  ReceivePort _port = ReceivePort();
  var videoCount;
  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    _isLoading = true;
    _permissionReady = false;

    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
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
      if (debug) {
        print('UI Isolate Callback: $data');
      }
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      dynamic progress = data[2];

      if (_tasks != null && _tasks!.isNotEmpty) {
        final task = _tasks!.firstWhere((task) => task.taskId == id);
        if (task.taskId != null) {
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
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_senddPort')!;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: customAppBar1(context, translate("Downloads_"))
          as PreferredSizeWidget?,
      body: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).primaryColorLight,
          child: Builder(
              builder: (context) => _isLoading
                  ? new Center(
                      child: new CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : _permissionReady
                      ? _items.length <= 1
                          ? BlankDownloadList()
                          : _buildDownloadList()
                      : _buildNoPermissionWarning()),
          onRefresh: refreshList),
    );
  }

  Widget _buildDownloadList() => Container(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: _items.map((item) {
            if (item.task == null) {
              return _buildListSection(item.name!);
            } else {
              if (item.task!.status == DownloadTaskStatus.complete ||
                  item.task!.status == DownloadTaskStatus.running ||
                  item.task!.status == DownloadTaskStatus.paused ||
                  item.task!.status == DownloadTaskStatus.failed) {
                return DownloadItem(
                  data: item,
                  onItemClick: (task) {
                    _openDownloadedFile(task).then((success) {
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              translate('Cannot_open_this_file'),
                            ),
                          ),
                        );
                      }
                    });
                  },
                  onAtionClick: (task) {
                    if (task.status == DownloadTaskStatus.undefined) {
                      _requestDownload(task);
                    } else if (task.status == DownloadTaskStatus.running) {
                      _pauseDownload(task);
                    } else if (task.status == DownloadTaskStatus.paused) {
                      _resumeDownload(task);
                    } else if (task.status == DownloadTaskStatus.complete) {
                      _delete(task);
                    } else if (task.status == DownloadTaskStatus.failed) {
                      _retryDownload(task);
                    }
                  },
                );
              } else {
                return SizedBox.shrink();
              }
            }
          }).toList(),
        ),
      );

  Widget _buildListSection(String title) => Container(
        padding: const EdgeInsets.only(
            left: 10.0, right: 10.0, top: 10, bottom: 15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              videoCount == 0
                  ? translate("No_Video")
                  : "$videoCount ${translate("Video_")}",
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: title == '0'
                      ? Theme.of(context).hintColor
                      : Theme.of(context).hintColor,
                  fontSize: 14.0),
            ),
          ],
        ),
      );

  Widget _buildNoPermissionWarning() => Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  translate(
                          'Please_grant_accessing_storage_permission_to_continue') +
                      ' -_-',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
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
                    fontSize: 20.0,
                  ),
                ),
              )
            ],
          ),
        ),
      );

  void _requestDownload(_TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link!,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
  }

  void _pauseDownload(_TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId!);
  }

  void _resumeDownload(_TaskInfo task) async {
    String? newTaskId = await FlutterDownloader.resume(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  void _retryDownload(_TaskInfo task) async {
    print("tt ${task.taskId}");
    String? newTaskId = await FlutterDownloader.retry(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  Future<bool> _openDownloadedFile(_TaskInfo? task) {
    var fileNamenew = task!.link!.split('/').last;

    var router = new MaterialPageRoute(
        builder: (BuildContext context) => DownloadedVideoPlayer(
              taskId: task.taskId,
              name: task.name,
              fileName: fileNamenew,
              downloadStatus: 0,
            ));
    Navigator.of(context).push(router);
    return Future.value(true);
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show();
    await Future.delayed(Duration(seconds: 2));
    getUpdates();
  }

  Future<String?> getUpdates() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FlutterDownloader.registerCallback(downloadCallback);
        _isLoading = true;
        _permissionReady = false;
        _prepare();
      } else {
        return null;
      }
    } on SocketException catch (e3) {
      print(e3.message);
      Fluttertoast.showToast(msg: translate("Connect_to_internet"));
      return null;
    } on Exception catch (e4) {
      print("Exception $e4");
      return null;
    }
    return null;
  }

  void _delete(_TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId!, shouldDeleteContent: true);

    task.type == 'M'
        ? cdb!.delete(
            DatabaseCreator.todoTable,
            where: "movie_id = ? AND vtype = ?",
            whereArgs: [task.id, task.type],
          )
        : cdb!.delete(DatabaseCreator.todoTable,
            where:
                "tvseries_id = ? AND vtype = ? AND season_id = ? AND episode_id = ?",
            whereArgs: [task.id, task.type, task.seasonId, task.episodeId]);
    setState(() {});
    setState(() {});
    setState(() {
      videoCount = videoCount - 1;
    });
    await _prepare();
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
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<Null> _prepare() async {
    var _videos = [];

    _videos = await cdb!.query(DatabaseCreator.todoTable);
    final tasks = await FlutterDownloader.loadTasks();
    setState(() {
      videoCount = _videos.length;
    });
    int count = 0;
    _tasks = [];
    _items = [];

    _tasks!.addAll(_videos.map((video) => _TaskInfo(
        id: video['vtype'] == 'M' ? video['movie_id'] : video['tvseries_id'],
        name: video['name'],
        link: video['info'],
        type: video['vtype'],
        seasonId: video['vtype'] == 'M' ? null : video['season_id'],
        episodeId: video['vtype'] == 'M' ? null : video['episode_id'])));

    var listLen = _videos.length;
    print("all videos : $_videos");
    _items.add(_ItemHolder(name: '$listLen'));
    for (int i = count; i < _tasks!.length; i++) {
      _items.add(_ItemHolder(name: _tasks![i].name, task: _tasks![i]));
      count++;
    }

    tasks?.forEach((task) {
      for (_TaskInfo info in _tasks!) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    _permissionReady = await _checkPermission();

    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await (getExternalStorageDirectory())
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }
}

class DownloadItem extends StatelessWidget {
  final _ItemHolder? data;
  final Function(_TaskInfo?)? onItemClick;
  final Function(_TaskInfo)? onAtionClick;

  DownloadItem({this.data, this.onItemClick, this.onAtionClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      margin: EdgeInsets.only(
        bottom: 16.0,
      ),
      child: InkWell(
        onTap: data!.task!.status == DownloadTaskStatus.complete
            ? () {
                onItemClick!(data!.task);
              }
            : null,
        child: Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                bottom: data!.task!.status == DownloadTaskStatus.running ||
                        data!.task!.status == DownloadTaskStatus.paused
                    ? 10.0
                    : 0.0,
              ),
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 8.0,
              ),
              width: double.infinity,
              height: 64.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data!.task!.name!,
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          data!.task!.type == 'M'
                              ? translate("Movie_")
                              : translate("Tv_Series"),
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _buildActionForTask(data!.task!),
                  ),
                ],
              ),
            ),
            data!.task!.status == DownloadTaskStatus.running ||
                    data!.task!.status == DownloadTaskStatus.paused
                ? Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: LinearProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      value: data!.task!.progress! / 100,
                    ),
                  )
                : Container()
          ].where((child) => child == child).toList(),
        ),
      ),
    );
  }

  Widget? _buildActionForTask(_TaskInfo task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return RawMaterialButton(
        onPressed: () {
          onAtionClick!(task);
        },
        child: Icon(Icons.file_download),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return RawMaterialButton(
        onPressed: () {
          onAtionClick!(task);
        },
        child: Icon(
          Icons.pause,
          color: Colors.red,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return RawMaterialButton(
        onPressed: () {
          onAtionClick!(task);
        },
        child: Icon(
          Icons.play_arrow,
          color: Colors.green,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            translate('Downloaded_'),
            style: TextStyle(color: Colors.green),
          ),
          RawMaterialButton(
            onPressed: () {
              onAtionClick!(task);
            },
            child: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return Text(
        translate('Canceled_'),
        style: TextStyle(
          color: Colors.red,
        ),
      );
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            translate('Failed_'),
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              onAtionClick!(task);
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
    } else if (task.status == DownloadTaskStatus.enqueued) {
      return Text(
        translate('Pending_'),
        style: TextStyle(
          color: Colors.orange,
        ),
      );
    } else {
      return null;
    }
  }
}

class _TaskInfo {
  final String? id;
  final String? name;
  final String? link;
  final String? type;
  final String? seasonId;
  final String? episodeId;

  String? taskId;
  dynamic progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;

  _TaskInfo(
      {this.id,
      this.name,
      this.link,
      this.type,
      this.seasonId,
      this.episodeId});
}

class _ItemHolder {
  final String? name;
  final _TaskInfo? task;

  _ItemHolder({this.name, this.task});
}
