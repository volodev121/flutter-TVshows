import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/common/apipath.dart';
import '/common/route_paths.dart';
import '/providers/main_data_provider.dart';
import '/ui/screens/actors_movies_grid.dart';
import '/ui/shared/appbar.dart';
import 'package:provider/provider.dart';

class ActorsGrid extends StatefulWidget {
  @override
  _ActorsGridState createState() => _ActorsGridState();
}

class _ActorsGridState extends State<ActorsGrid> {
  List<Widget>? videoList;

  @override
  Widget build(BuildContext context) {
    var dw = MediaQuery.of(context).size.width;
    print(dw);
    var actorsList =
        Provider.of<MainProvider>(context, listen: false).actorList;
    return Scaffold(
      appBar:
          customAppBar(context, translate("Artist_")) as PreferredSizeWidget?,
      body: Container(
        child: GridView.builder(
          itemCount: actorsList.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          padding: EdgeInsets.only(top: 20.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? 4
                      : dw >= 834
                          ? 3
                          : 2,
              mainAxisSpacing:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? 4
                      : dw >= 834
                          ? 3
                          : 2,
              childAspectRatio: dw >= 834 ? 1.0 : 0.9),
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(
                      width: 2.0,
                      color: Colors.white,
                    ),
                  ),
                  child: Material(
                    borderRadius: new BorderRadius.circular(100.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100.0),
                      child: ClipRRect(
                        borderRadius: new BorderRadius.circular(100.0),
                        child: new FadeInImage.assetNetwork(
                          image:
                              "${APIData.actorsImages}${actorsList[index].image}",
                          placeholder: "assets/placeholder_box.jpg",
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/placeholder_box.jpg",
                              fit: BoxFit.cover,
                            );
                          },
                          imageScale: 1.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RoutePaths.actorMoviesGrid,
                          arguments: ActorMoviesGrid(actorsList[index]),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  "${actorsList[index].name}",
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
