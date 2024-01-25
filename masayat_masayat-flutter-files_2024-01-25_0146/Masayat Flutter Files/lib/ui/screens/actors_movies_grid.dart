import 'package:flutter/material.dart';
import 'package:nexthour/common/unity_ads.dart';
import '/common/apipath.dart';
import '/common/route_paths.dart';
import '/models/episode.dart';
import '/models/genre_model.dart';
import '/providers/actor_movies_provider.dart';
import '/ui/screens/video_detail_screen.dart';
import '/ui/shared/appbar.dart';
import '/ui/shared/blank_history.dart';
import 'package:provider/provider.dart';

class ActorMoviesGrid extends StatefulWidget {
  ActorMoviesGrid(this.actorDetails);
  final Actor actorDetails;

  @override
  _ActorMoviesGridState createState() => _ActorMoviesGridState();
}

class _ActorMoviesGridState extends State<ActorMoviesGrid> {
  List<Widget>? videoList;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    showInterstitialVideoAds();
    setState(() {
      _visible = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<ActorMoviesProvider>(context, listen: false)
          .getActorsMovies(context, widget.actorDetails.id.toString());
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var actorMoviesList =
        Provider.of<ActorMoviesProvider>(context).actorMoviesTVList;
    return Scaffold(
      appBar: customAppBar(context, "${widget.actorDetails.name}")
          as PreferredSizeWidget?,
      body: _visible == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : actorMoviesList.length == 0
              ? NoMovies()
              : Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                  child: GridView.builder(
                    itemCount: actorMoviesList.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 15.0,
                        mainAxisSpacing: 15.0,
                        childAspectRatio: 5 / 8.0),
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          Container(
                            height: 160,
                            width: 110,
                            child: Material(
                              borderRadius: new BorderRadius.circular(10.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10.0),
                                child: ClipRRect(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  child: actorMoviesList[index].thumbnail ==
                                          null
                                      ? Image.asset(
                                          "assets/placeholder_box.jpg",
                                          fit: BoxFit.cover,
                                        )
                                      : FadeInImage.assetNetwork(
                                          image: actorMoviesList[index].type ==
                                                  DatumType.M
                                              ? "${APIData.movieImageUri}${actorMoviesList[index].thumbnail}"
                                              : "${APIData.tvImageUriTv}${actorMoviesList[index].thumbnail}",
                                          placeholder:
                                              "assets/placeholder_box.jpg",
                                          imageScale: 1.0,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, RoutePaths.videoDetail,
                                      arguments: VideoDetailScreen(
                                          actorMoviesList[index]));
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )),
    );
  }
}
