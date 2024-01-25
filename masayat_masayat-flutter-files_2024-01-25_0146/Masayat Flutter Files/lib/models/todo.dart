import '/services/repository/database_creator.dart';

class Todo {
  dynamic  id;
  String? name;
  String? path;
  String? type;
  String? movieId;
  String? tvSeriesId;
  String? seasonId;
  String? episodeId;
  String? dTaskId;
  dynamic dUserId;
  dynamic  progress;

  Todo({
    this.id,
    this.name,
    this.path,
    this.type,
    this.movieId,
    this.tvSeriesId,
    this.seasonId,
    this.episodeId,
    this.dTaskId,
    this.dUserId,
    this.progress,
  });

  factory Todo.fromMap(Map<String, dynamic> json) => new Todo(
      id: json[DatabaseCreator.id],
      name: json[DatabaseCreator.name],
      path: json[DatabaseCreator.info],
      type: json[DatabaseCreator.type],
      movieId: json[DatabaseCreator.movieId],
      tvSeriesId: json[DatabaseCreator.tvSeriesId],
      seasonId: json[DatabaseCreator.seasonId],
      episodeId: json[DatabaseCreator.episodeId],
      dTaskId: json[DatabaseCreator.dTaskId],
      dUserId: json[DatabaseCreator.dUserId],
      progress: json[DatabaseCreator.progress]);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "id": id,
      "name": name,
      "info": path,
      "vtype": type,
      "movie_id": movieId,
      "tvseries_id": tvSeriesId,
      "season_id": seasonId,
      "episode_id": episodeId,
      "dtask_id": dTaskId,
      "user_id": dUserId,
      "progress": progress
    };

    return map;
  }
}
