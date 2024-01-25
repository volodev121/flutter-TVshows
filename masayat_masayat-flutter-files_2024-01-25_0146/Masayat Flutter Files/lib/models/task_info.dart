import 'package:flutter_downloader/flutter_downloader.dart';

class TaskInfo {
  final String? name;
  final String? ifLink;
  final String? hdLink;
  final String? link360;
  final String? link480;
  final String? link720;
  final String? link1080;
  final dynamic  eIndex;
  String? taskId;
  dynamic  progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;

  TaskInfo({this.name, this.ifLink, this.hdLink, this.link360, this.link480, this.link720, this.link1080, this.taskId, this.eIndex});
}

class ItemHolder {
  final String? name;
  final TaskInfo? task;

  ItemHolder({this.name, this.task});
}