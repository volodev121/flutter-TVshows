import '/services/repository/database_creator.dart';

class ProgressData {
  String? dTaskId;
  dynamic  progress;

  ProgressData({this.dTaskId, this.progress});

  factory ProgressData.fromMap(Map<String, dynamic> json) => new ProgressData(
      dTaskId: json[DatabaseCreator.dTaskId],
      progress: json[DatabaseCreator.progress]);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{"dtask_id": dTaskId, "progress": progress};

    return map;
  }
}
