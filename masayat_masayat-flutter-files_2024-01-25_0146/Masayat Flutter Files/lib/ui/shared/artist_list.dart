import 'package:flutter/material.dart';
import '/common/apipath.dart';
import '/common/route_paths.dart';
import '/models/datum.dart';
import '/models/genre_model.dart';
import '/ui/screens/actor_screen.dart';

class ArtistList extends StatefulWidget {
  ArtistList(this.videoDetail);

  final Datum? videoDetail;

  @override
  _ArtistListState createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
  List<Actor?>? actorsList;

  @override
  Widget build(BuildContext context) {
    widget.videoDetail!.actors!.removeWhere((value) => value == null);
    actorsList = widget.videoDetail!.actors;
    return actorsList!.length == 0
        ? SizedBox.shrink()
        : Container(
            height: 152,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.only(left: 15.0),
              itemCount: actorsList!.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(40.0),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.only(right: 15.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(1.0),
                                Theme.of(context).primaryColorDark
                              ],
                              stops: [
                                0.3,
                                0.8
                              ]),
                          borderRadius: BorderRadius.circular(0.0),
                          border: Border.all(
                            width: 0.0,
                            color: Colors.white,
                            style: BorderStyle.none,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(0.0),
                          child: actorsList![index]!.image == null
                              ? Image.asset(
                                  "assets/placeholder_box.jpg",
                                  fit: BoxFit.cover,
                                  height: 150.0,
                                  width: 100.0,
                                )
                              : FadeInImage.assetNetwork(
                                  placeholder: "assets/placeholder_box.jpg",
                                  image:
                                      "${APIData.actorsImages}${actorsList![index]!.image}",
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/placeholder_box.jpg",
                                      fit: BoxFit.cover,
                                      height: 150.0,
                                      width: 100.0,
                                    );
                                  },
                                  fit: BoxFit.cover,
                                  height: 150.0,
                                  width: 100.0,
                                ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        height: 152.0,
                        width: 101.3,
                        margin: EdgeInsets.only(
                          right: 15.0,
                        ),
                        padding: EdgeInsets.only(
                          bottom: 20.0,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(0.1),
                                Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(0.7),
                                Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(0.95),
                                Theme.of(context).primaryColorDark
                              ],
                              stops: [
                                0.3,
                                0.65,
                                0.85,
                                1.0
                              ]),
                        ),
                        child: Text(
                          '${actorsList![index]!.name}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    RoutePaths.actorScreen,
                    arguments: ActorScreen(actorsList![index]),
                  ),
                );
              },
            ),
          );
  }
}
